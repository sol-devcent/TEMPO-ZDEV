REPORT zmm_po_so_upload.
************************************************************************
*                REPORT                                                *
*----------------------------------------------------------------------*
* ABAP Name   : ZMM_PO_SO_UPLOAD                                       *
* Created by  : Mahendro K                                             *
* Created on  : 12-18 Juli 2002                                        *
* Version     : 1.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description : Upload PO STO Allocation / PO & SO for EC allocation   *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
* Revised     : 17 September 2002
*----------------------------------------------------------------------*
TABLES : sscrfields, eban.

TYPES:
  BEGIN OF t_excel,
    row         LIKE alsmex_tabline-row,
    col         LIKE alsmex_tabline-col,
    value       LIKE alsmex_tabline-value,
  END OF t_excel,

  BEGIN OF t_po_so,
     lifnr(10)  TYPE c,
     bsart      LIKE ekko-bsart,
     ekgrp      LIKE ekko-ekgrp,
     bedat(10)  TYPE c,
     eindt(10)  TYPE c,
     matnr      LIKE ekpo-matnr,
     menge      LIKE ekpo-menge,
     werks      LIKE ekpo-werks,
     lgort      LIKE ekpo-lgort,
     bsgru      LIKE ekpo-bsgru,
     reslo      TYPE reslo,
     charg      TYPE charg_d,
     absgr      TYPE ekko-absgr,
     kunnr      TYPE kna1-kunnr,
     post       TYPE int4,
     afnam      TYPE eban-afnam,
     bednr      TYPE ekpo-bednr,
*     netprice   TYPE BAPICUREXT,
  END OF t_po_so,

  BEGIN OF ty_prio,
    ebeln       TYPE ekpo-ebeln,
    ebelp       TYPE ekpo-ebelp,
    matnr       TYPE ekpo-matnr,
    lprio       TYPE mepo1331-lprio,
  END OF ty_prio.

TYPES: BEGIN OF t_messtab.
        INCLUDE STRUCTURE bdcmsgcoll.
TYPES: END OF t_messtab.

DATA:
    i_excel     TYPE t_excel OCCURS 0,
    wa_excel    TYPE t_excel,
    i_po_so     TYPE t_po_so OCCURS 0,
    wa_po_so    TYPE t_po_so,
    v_bukrs     LIKE t001k-bukrs,
    v_bsart     LIKE eban-bsart,
    v_ekorg     TYPE ekorg,
    v_vkorg     LIKE tvko-vkorg,
    v_ebelp     LIKE ekpo-ebelp,
    v_kunnr     LIKE kna1-kunnr,
    v_lifnr     LIKE lfa1-lifnr,
    v_reswk     LIKE t001w-werks,
    v_werks     LIKE eban-werks,
    v_lgort     LIKE eban-lgort,
    i_bsart     LIKE eban-bsart,
    i_ekgrp     LIKE eban-ekgrp,
    i_bedat(10) TYPE c,
    i_eindt(10) TYPE c,
    i_date      TYPE dats,
    new_record  TYPE flag,
    with_so     TYPE flag.

DATA: poh1 LIKE bapimepoheader,
      poh2 LIKE bapimepoheaderx,
      poi1 LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
      poi2 LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
      poi3 LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
      poi4 LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE,
      po_num LIKE bapimepoheader-po_number.

DATA: soh1 LIKE bapisdhd1,
      soi1 LIKE bapisditm OCCURS 0 WITH HEADER LINE,
      soi2 LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
      soi3 LIKE bapischdl OCCURS 0 WITH HEADER LINE,
      so_num LIKE bapivbeln-vbeln.

DATA: pri1 LIKE bapiebanc OCCURS 0 WITH HEADER LINE,
      pr_num LIKE bapiebanc-preq_no.

DATA: l_t_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
      l_t_return2 LIKE bapireturn OCCURS 0 WITH HEADER LINE.

DATA: l_error_found TYPE c,
      txtmsg(100)   TYPE c.

DATA: gt_prio   TYPE STANDARD TABLE OF ty_prio.

INCLUDE zmm_po_so_upload_top.

DATA : gt_zt16fw  TYPE STANDARD TABLE OF zt16fw INITIAL SIZE 0.
DATA : gt_eban    TYPE STANDARD TABLE OF eban INITIAL SIZE 0.
DATA : BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE eban.
DATA :  vendor  LIKE ekpo-infnr,
        bsgru   LIKE ekpo-bsgru,
        vstel   LIKE tvkol-vstel,
        check,
        stats(4).
DATA : END OF gt_out.

INCLUDE zmm_po_so_upload_cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-004.
SELECT-OPTIONS so_banfn   FOR eban-banfn MODIF ID ban.
SELECT-OPTIONS so_badat   FOR eban-badat MODIF ID bad.
SELECT-OPTIONS so_werks   FOR eban-werks MODIF ID wer.
SELECT-OPTIONS so_lgort   FOR eban-lgort MODIF ID lgo.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS po_sto    RADIOBUTTON GROUP grp  USER-COMMAND rad DEFAULT 'X'.
PARAMETERS po_so     RADIOBUTTON GROUP grp MODIF ID obs.
PARAMETERS pr        RADIOBUTTON GROUP grp.
PARAMETERS rt_po_so  RADIOBUTTON GROUP grp MODIF ID obs.
PARAMETERS po_nb     RADIOBUTTON GROUP grp.
PARAMETERS po_o2o    RADIOBUTTON GROUP grp.
PARAMETERS po_rnb    RADIOBUTTON GROUP grp.
PARAMETERS file_i    LIKE rlgrap-filename MODIF ID fil. "File data
SELECTION-SCREEN SKIP 1.
PARAMETERS prpo_sto  RADIOBUTTON GROUP grp.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_chgpr   RADIOBUTTON GROUP grp.
SELECTION-SCREEN COMMENT 17(27) text-004 FOR FIELD p_chgpr.
PARAMETERS p_finm1  LIKE rlgrap-filename MODIF ID fi1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_chgdn   RADIOBUTTON GROUP grp.
SELECTION-SCREEN COMMENT 17(27) text-005 FOR FIELD p_chgdn.
PARAMETERS p_finm2  LIKE rlgrap-filename MODIF ID fi2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK notes WITH FRAME TITLE text-002.
SELECTION-SCREEN COMMENT 1(60) text-003.
SELECTION-SCREEN END   OF BLOCK notes.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.
  PERFORM f_modify_screen USING : 'OBS' '0' ''. "Remove Obsolete

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file_i.
  PERFORM call_file USING file_i.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_finm1.
  PERFORM call_file USING p_finm1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_finm2.
  PERFORM call_file USING p_finm2.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

START-OF-SELECTION.
  CASE 'X'.
    WHEN prpo_sto.
      PERFORM f_get_data_pr_po_sto.
      PERFORM f_process_pr_po_sto.
      PERFORM f_print_data.

    WHEN p_chgpr.
      PERFORM f_get_data1 USING p_finm1.
      PERFORM f_po_change.

    WHEN p_chgdn.
      SUBMIT zmmsrp_e001
      WITH pa_fname  EQ  p_finm2
      AND RETURN.

    WHEN OTHERS.
      PERFORM f_get_data USING file_i.
      CLEAR new_record.
      CLEAR txtmsg.
      CLEAR with_so.
      IF po_so = 'X' OR rt_po_so = 'X'.
        with_so = 'X'.
      ENDIF.

      IF po_sto = 'X' OR po_so = 'X' OR rt_po_so = 'X'.
        LOOP AT i_po_so INTO wa_po_so.

          IF wa_po_so-lifnr <> '' OR wa_po_so-ekgrp <> ''.
* ----> Check 1 st record, NEW_RECORD eq space is 1st record
            IF new_record = 'X'.
* Call BAPI Function
              PERFORM f_bapi_process USING with_so
                                           poh1
                                           poh2
                                           poi1[]
                                           poi2[]
                                           poi3[]
                                           poi4[]
                                           soh1
                                           soi1[]
                                           soi2[]
                                           soi3[].
            ENDIF.

            new_record = 'X'.
            v_ebelp = '00010'.
            v_bsart = wa_po_so-bsart.

* Find company code
            SELECT SINGLE bukrs FROM t001k INTO v_bukrs
            WHERE bwkey = wa_po_so-werks.
            IF sy-subrc <> '0'.
              MESSAGE e002(zz) WITH 'Company code not found for plant '
            wa_po_so-werks.
            ENDIF.


************ Declare PO header data ************
* Isi header table

* i_date is for sales order requirement date
            i_eindt = wa_po_so-eindt.
            i_bedat = wa_po_so-bedat.
            DATA: datmm TYPE i,
                  datjj TYPE i,
                  rest  TYPE i,
                  tt(2).

            datmm = i_eindt+3(2).
            CASE datmm.
              WHEN 1.  tt = 31.
              WHEN 2.  tt = 28.
              WHEN 3.  tt = 31.
              WHEN 4.  tt = 30.
              WHEN 5.  tt = 31.
              WHEN 6.  tt = 30.
              WHEN 7.  tt = 31.
              WHEN 8.  tt = 31.
              WHEN 9.  tt = 30.
              WHEN 10. tt = 31.
              WHEN 11. tt = 30.
              WHEN 12. tt = 31.
            ENDCASE.
            IF datmm = 2.
              datjj = i_eindt+6(4).
              rest  = datjj MOD 4.
              IF rest = 0.
                tt = 29.
              ENDIF.
            ENDIF.

            CONCATENATE i_eindt+6(4) i_eindt+3(2) tt INTO i_date.
* Remove by MKO to make sure discount in PO is current discount.
*         POH1-DOC_DATE   = ( i_date - 30 ).
*          CONCATENATE i_eindt+6(4) i_eindt+3(2) '01' INTO POH1-DOC_DATE.
            CONCATENATE i_bedat+6(4) i_bedat+3(2) i_bedat(2) INTO poh1-doc_date.

*          POH1-DOC_DATE   = SY-DATUM.

*          poh1-doc_date   = wa_po_so-bedat.

            IF v_bukrs EQ '8020'.
              IF wa_po_so-ekgrp = 'O2O'.
                v_ekorg = 'O2O'.
              ELSE.
                v_ekorg = 'SOM'.
              ENDIF.
            ELSEIF v_bukrs EQ '8070'.
              v_ekorg = 'SUT'.
            ELSEIF v_bukrs EQ '8220'.
              v_ekorg = 'ERV'.
            ENDIF.

            poh1-creat_date = sy-datlo.
            poh1-comp_code  = v_bukrs.
            poh1-purch_org  = v_ekorg.
            poh1-pur_group  = wa_po_so-ekgrp.

            soh1-purch_date = i_date.
            sy-subrc = '1'.
            WHILE sy-subrc <> '0'.
* Sales order date is PO date minus 1 day
              i_date = i_date - 1.
* Check if day is working day
              CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
                EXPORTING
                  date                       = i_date
                  factory_calendar_id        = 'T0'
                  message_type               = 'E'
                EXCEPTIONS
                  date_after_range           = 1
                  date_before_range          = 2
                  date_invalid               = 3
                  date_no_workingday         = 4
                  factory_calendar_not_found = 5
                  message_type_invalid       = 6.
            ENDWHILE.
            poh2-doc_date   = 'X'.
            poh2-creat_date = 'X'.
            poh2-purch_org  = 'X'.
            poh2-pur_group  = 'X'.

* Check whether PO SO / Retur PO SO
            IF po_so = 'X' OR rt_po_so = 'X'.
*   Find sales organization
              SELECT SINGLE vkorg FROM tvko INTO v_vkorg
              WHERE bukrs = v_bukrs.
              IF sy-subrc <> '0'.
                MESSAGE e002(zz) WITH 'Sales organization not found for Company '
                      v_bukrs.
              ENDIF.

*   Find customer
              CONCATENATE 'TBA' wa_po_so-werks INTO v_kunnr.

              poh1-vendor     = wa_po_so-lifnr.
              poh1-doc_type   = 'ZNB'.
              soh1-doc_type   = 'ZOCW'.

* Check whether Retur PO SO
              IF rt_po_so = 'X'.
                IF wa_po_so-bsart = 'RZNB' OR
                  wa_po_so-bsart = 'RSUT'.
                  poh1-doc_type      = 'RZNB'.
                  soh1-doc_type      = 'ZRCW'.
                  poh1-reason_cancel = wa_po_so-bsgru.
                  poh2-reason_cancel = 'X'.
                ELSE.
                  CONCATENATE 'Doc. type' wa_po_so-bsart
                              'can not upload with Ret PO SO'
                        INTO txtmsg SEPARATED BY space.
                  MESSAGE e002(zz) WITH txtmsg.
                ENDIF.
              ENDIF.
              poh1-gr_message = 'X'.
              poh2-vendor     = 'X'.
              poh2-doc_type   = 'X'.
              poh2-gr_message = 'X'.
            ENDIF.

* Check whether Retur PO STO
            IF po_sto = 'X'.
              IF wa_po_so-bsart = 'UB' OR
                wa_po_so-bsart = 'ZRL'.
                poh1-suppl_plnt = wa_po_so-lifnr.
                poh2-suppl_plnt = 'X'.
              ELSEIF wa_po_so-bsart = 'ZB' OR
                wa_po_so-bsart = 'ZSUT'OR
                wa_po_so-bsart = 'ZICO'.
                SELECT SINGLE werks lifnr FROM t001w INTO (v_reswk, v_lifnr)
                WHERE lifnr = wa_po_so-lifnr.
                poh1-vendor     = v_lifnr.
                poh2-vendor     = 'X'.
                IF wa_po_so-bsart = 'ZICO'.
                  poh1-suppl_plnt     = v_reswk.
                  poh2-suppl_plnt     = 'X'.
                ENDIF.
              ELSE.
                CLEAR txtmsg.
                CONCATENATE 'Doc. type' wa_po_so-bsart 'can not upload with PO STO'
                      INTO txtmsg SEPARATED BY space.
                MESSAGE e002(zz) WITH txtmsg.
              ENDIF.
              poh1-doc_type   = wa_po_so-bsart.
              poh2-doc_type   = 'X'.
            ENDIF.

            soh1-sales_org  = v_vkorg.
            soh1-distr_chan = '10'.
            soh1-division   = '00'.
            soh1-sales_off  = wa_po_so-lifnr+3(4).
            soh1-ord_reason = 'A10'.
            soh1-dlvschduse = 'M'.
            soh1-req_date_h = i_date.

          ENDIF.

* ----> Check Last record
          IF wa_po_so-matnr = ''.
            EXIT.
          ENDIF.

* Isi item table
************ Declare PO item data ************
          poi1-po_item      = v_ebelp.
          poi1-material     = wa_po_so-matnr.
* Check for minus qty
          IF wa_po_so-menge < 0.
            MESSAGE e002(zz) WITH
            'Quantity minus for' wa_po_so-matnr 'in plant' wa_po_so-werks.
          ENDIF.
          poi1-quantity     = wa_po_so-menge.
          poi1-plant        = wa_po_so-werks.
          poi1-stge_loc     = wa_po_so-lgort.
          poi1-order_reason = wa_po_so-bsgru.
          poi1-suppl_stloc  = wa_po_so-reslo.
          poi1-batch        = wa_po_so-charg.
          poi1-trackingno   = wa_po_so-bednr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_po_so-kunnr
            IMPORTING
              output = poi1-customer.

*      poi1-net_price    = wa_po_so-netprice.
*      poi1-price_unit   = 1.
*      poi1-pricedate    = '4'.
*      poi1-price_date   = sy-datum.
*      poi1-po_price     = '2'.

          IF wa_po_so-bsart = 'RZNB' OR
            wa_po_so-bsart = 'RSUT'.
            poi1-ret_item = 'X'.
            poi2-ret_item = 'X'.
          ENDIF.

          poi2-po_item      = v_ebelp.
          poi2-po_itemx     = 'X'.
          poi2-material     = 'X'.
          poi2-quantity     = 'X'.
          poi2-plant        = 'X'.
          poi2-stge_loc     = 'X'.
          poi2-batch        = 'X'.
          poi2-trackingno   = 'X'.
          poi2-customer     = 'X'.
*      poi2-net_price    = 'X'.
*      poi2-price_unit   = 'X'.
*      poi2-pricedate    = 'X'.
*      poi2-price_date   = 'X'.
*      poi2-po_price     = 'X'.
* If retur PO SO
          IF rt_po_so = 'X'.
            poi1-ret_item ='X'.
            poi2-ret_item ='X'.
          ELSE.
            poi2-order_reason = 'X'.
          ENDIF.
          poi2-suppl_stloc  = 'X'.
          APPEND poi1.
          APPEND poi2.

          poi3-po_item        = v_ebelp.
          poi3-sched_line     = 1.
          poi3-del_datcat_ext = 'T'.
* Last date of month
*          i_eindt(2)          = tt.
          poi3-delivery_date  = i_eindt.
          poi3-quantity       = wa_po_so-menge.
          APPEND poi3.

          poi4-po_item        = v_ebelp.
          poi4-po_itemx       = 'X'.
          poi4-sched_line     = 1.
          poi4-del_datcat_ext = 'X'.
          poi4-delivery_date  = 'X'.
          poi4-quantity       = 'X'.
          APPEND poi4.

          soi1-itm_number     = v_ebelp.
          soi1-material       = wa_po_so-matnr.
          soi1-plant          = wa_po_so-lifnr+3(4).
          APPEND soi1.

          soi2-partn_role     = 'SP'.
          soi2-partn_numb     = v_kunnr.
          APPEND soi2.

          soi3-itm_number     = v_ebelp.
          soi3-req_date       = i_date.
          soi3-req_qty        = wa_po_so-menge.
          APPEND soi3.

          ADD 10 TO v_ebelp.
        ENDLOOP.

* Call BAPI Function
        PERFORM f_bapi_process USING with_so
                                     poh1
                                     poh2
                                     poi1[]
                                     poi2[]
                                     poi3[]
                                     poi4[]
                                     soh1
                                     soi1[]
                                     soi2[]
                                     soi3[].

      ELSEIF pr = 'X'.

        SELECT *
          FROM zt16fw
          INTO CORRESPONDING FIELDS OF TABLE gt_zt16fw.
        SORT gt_zt16fw BY extwg.
        DELETE ADJACENT DUPLICATES FROM gt_zt16fw COMPARING extwg.

        LOOP AT i_po_so INTO wa_po_so.
          IF wa_po_so-bsart <> 'ZPR'.
            IF wa_po_so-bsgru <> ''.
              txtmsg = 'File can not upload because of error in data'.
              MESSAGE e002(zz) WITH txtmsg.
            ENDIF.
          ENDIF.

          ON CHANGE OF wa_po_so-lifnr OR wa_po_so-ekgrp OR wa_po_so-werks
                    OR wa_po_so-lgort.
            IF wa_po_so-lifnr <> ''      OR wa_po_so-ekgrp <> '' OR
               wa_po_so-werks <> v_werks OR wa_po_so-lgort <> v_lgort.
* ----> Check 1 st record, NEW_RECORD eq space is 1st record
              IF new_record = 'X'.
* Call BAPI Function
                PERFORM f_bapi_process2 USING pri1[].
              ENDIF.

              new_record = 'X'.
              v_ebelp = '00010'.
              v_lifnr = wa_po_so-lifnr.
              v_werks = wa_po_so-werks.
              v_lgort = wa_po_so-lgort.
              i_bsart = wa_po_so-bsart.
              i_ekgrp = wa_po_so-ekgrp.
              i_eindt = wa_po_so-eindt.
              i_bedat = wa_po_so-bedat.
            ENDIF.
          ENDON.
* ----> Check Last record
          IF wa_po_so-matnr = ''.
            EXIT.
          ENDIF.

          pri1-preq_item  = v_ebelp.
          pri1-doc_type   = i_bsart.
          IF pri1-doc_type = 'UB'.
            pri1-item_cat      = '7'.
            pri1-suppl_plnt    = v_lifnr.
            pri1-zzsuppl_stloc = wa_po_so-reslo.
          ELSE.
            pri1-trackingno = wa_po_so-reslo.
          ENDIF.
          pri1-pur_group  = i_ekgrp.
          pri1-material   = wa_po_so-matnr.
          pri1-plant      = v_werks.
          pri1-store_loc  = wa_po_so-lgort.
          pri1-preq_name  = wa_po_so-afnam.

* Check for minus qty
          IF wa_po_so-menge < 0.
            MESSAGE e002(zz) WITH
            'Quantity minus for' wa_po_so-matnr 'in plant' wa_po_so-werks.
          ENDIF.

          IF wa_po_so-bsart = 'ZPR'.
            PERFORM f_cek_quantity USING wa_po_so-matnr wa_po_so-menge.
          ENDIF.

          pri1-quantity   = wa_po_so-menge.
          pri1-gr_ind     = 'X'.
          pri1-ir_ind     = 'X'.
          PERFORM convert_date
                    USING i_eindt
                          pri1-deliv_date.
          PERFORM convert_date
                    USING i_bedat
                          pri1-preq_date.
          APPEND pri1.

          ADD 10 TO v_ebelp.

        ENDLOOP.

        PERFORM f_bapi_process2 USING pri1[].
      ENDIF.

      CASE 'X'.
        WHEN po_nb OR po_rnb OR po_o2o.
          PERFORM f_validasi_data.

          IF l_error_found IS INITIAL.
            PERFORM f_process_nb.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
  ENDCASE.

*---------------------------------------------------------------------*
*       FORM CALL_FILE                                                *
*---------------------------------------------------------------------*
*  -->  FILENAME                                                      *
*---------------------------------------------------------------------*
FORM call_file USING filename.
  DATA : v_repid LIKE sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = v_repid
      dynpro_number = syst-dynnr
      field_name    = 'PATH'
    IMPORTING
      file_name     = filename.
ENDFORM.                    "CALL_FILE

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*  -->  FILENAME                                                      *
*---------------------------------------------------------------------*
FORM f_get_data USING filename.
  DATA: v_flag_mater(1) TYPE c.

  DATA : lv_post    TYPE int4,
         lv_bsart   TYPE ekko-bsart.

  REFRESH i_excel.
* GET DATA FROM EXCEL FILE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename "INPUT FROM SELECTION SCREEN
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 16
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR i_po_so.
  CLEAR wa_excel.
  SORT i_excel BY row col value.
  LOOP AT i_excel INTO wa_excel.
    IF wa_excel-col = '0001'.
      CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
        EXPORTING
          i_input  = wa_excel-value
        IMPORTING
          e_output = wa_po_so-lifnr.
*      move wa_excel-value to wa_PO_SO-LIFNR.
    ENDIF.
    IF wa_excel-col = '0002'.
      CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
        EXPORTING
          i_input  = wa_excel-value
        IMPORTING
          e_output = wa_po_so-bsart.

      IF wa_po_so-bsart IS NOT INITIAL.
        lv_bsart  = wa_po_so-bsart.
      ENDIF.
*      move wa_excel-value to wa_PO_SO-BSART.
    ENDIF.
    IF wa_excel-col = '0003'.
      MOVE wa_excel-value TO wa_po_so-ekgrp.
    ENDIF.
    IF wa_excel-col = '0004'.
      MOVE wa_excel-value TO wa_po_so-bedat.
    ENDIF.
    IF wa_excel-col = '0005'.
      MOVE wa_excel-value TO wa_po_so-eindt.
    ENDIF.
    IF wa_excel-col = '0006'.
      MOVE wa_excel-value TO wa_po_so-matnr.
    ENDIF.
    IF wa_excel-col = '0007'.
      MOVE wa_excel-value TO wa_po_so-menge.
    ENDIF.
    IF wa_excel-col = '0008'.
      MOVE wa_excel-value TO wa_po_so-werks.
    ENDIF.
    IF wa_excel-col = '0009'.
      MOVE wa_excel-value TO wa_po_so-lgort.
    ENDIF.
    IF wa_excel-col = '0010'.
      CASE 'X'.
        WHEN po_nb.
          CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
            EXPORTING
              i_input  = wa_excel-value
            IMPORTING
              e_output = wa_po_so-bsgru.
        WHEN po_rnb.
          MOVE wa_excel-value TO wa_po_so-absgr.
        WHEN pr.
          MOVE wa_excel-value TO wa_po_so-afnam.
        WHEN OTHERS.
          CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
            EXPORTING
              i_input  = wa_excel-value
            IMPORTING
              e_output = wa_po_so-bsgru.
      ENDCASE.
*      move wa_excel-value to wa_PO_SO-BSGRU.
    ENDIF.
    IF wa_excel-col = '0011'.
      CASE 'X'.
        WHEN po_rnb.
          IF lv_bsart = 'RNB'.
            MOVE wa_excel-value TO wa_po_so-charg.
          ELSE.
            MOVE wa_excel-value TO wa_po_so-bednr.
          ENDIF.
        WHEN OTHERS.
          MOVE wa_excel-value TO wa_po_so-reslo.
      ENDCASE.
    ENDIF.

    IF wa_excel-col = '0012'.
      CASE 'X'.
        WHEN po_sto.
          MOVE wa_excel-value TO wa_po_so-kunnr.
        WHEN OTHERS.
          MOVE wa_excel-value TO wa_po_so-charg.
      ENDCASE.
    ENDIF.
*    IF wa_excel-col = '0013'.
*      REPLACE ALL OCCURRENCES OF '.' in wa_excel-value WITH ' '.
*      REPLACE ALL OCCURRENCES OF ',' in wa_excel-value WITH '.'.
*      CONDENSE wa_excel-value.
*      MOVE wa_excel-value TO wa_po_so-netprice.
*    ENDIF.

    AT END OF  row.
      CASE 'X'.
        WHEN po_nb OR po_rnb OR po_o2o.
          IF wa_po_so-lifnr IS NOT INITIAL.
            ADD 1 TO lv_post.
          ENDIF.
          wa_po_so-post = lv_post.
        WHEN OTHERS.
      ENDCASE.

      APPEND wa_po_so TO i_po_so.
      CLEAR  wa_po_so.
    ENDAT.
    CLEAR wa_excel.
  ENDLOOP.

  CASE 'X'.
    WHEN po_nb OR po_rnb OR po_o2o.
    WHEN OTHERS.
      APPEND wa_po_so TO i_po_so.
  ENDCASE.
ENDFORM.                    " f_get_data

*---------------------------------------------------------------------*
*       FORM CONVERT_DATE                                             *
*---------------------------------------------------------------------*
*  -->  I_DATE                                                        *
*  <--  E_DATE                                                        *
*---------------------------------------------------------------------*
FORM convert_date USING i_date LIKE wa_po_so-eindt
                        e_date LIKE eban-lfdat.

  DATA: datmm TYPE i,
        datjj TYPE i,
        rest  TYPE i,
        tt(2).

  datmm = i_date+3(2).
  CASE datmm.
    WHEN 1.  tt = 31.
    WHEN 2.  tt = 28.
    WHEN 3.  tt = 31.
    WHEN 4.  tt = 30.
    WHEN 5.  tt = 31.
    WHEN 6.  tt = 30.
    WHEN 7.  tt = 31.
    WHEN 8.  tt = 31.
    WHEN 9.  tt = 30.
    WHEN 10. tt = 31.
    WHEN 11. tt = 30.
    WHEN 12. tt = 31.
  ENDCASE.
  IF datmm = 2.
    datjj = i_date+6(4).
    rest  = datjj MOD 4.
    IF rest = 0.
      tt = 29.
    ENDIF.
  ENDIF.

*  CONCATENATE i_date+6(4) i_date+3(2) tt INTO e_date.
  CONCATENATE i_date+6(4) i_date+3(2) i_date(2) INTO e_date.
ENDFORM.                    " CONVERT_DATE

*---------------------------------------------------------------------*
*       FORM f_BAPI_process                                           *
*---------------------------------------------------------------------*
*      -->I_POH1 LIKE POH1
*      -->I_POH2 LIKE POH2
*      -->I_POI1 LIKE POI1[]
*      -->I_POI2 LIKE POI2[]
*      -->I_POI3 LIKE POI3[]
*      -->I_POI4 LIKE POI4[]
*      -->I_SOH1 LIKE SOH1
*      -->I_SOI1 LIKE SOI1[]
*      -->I_SOI2 LIKE SOI2[]
*      -->I_SOI3 LIKE SOI3[]
*---------------------------------------------------------------------*
FORM f_bapi_process
          USING  so_flag LIKE po_so
                 i_poh1 LIKE bapimepoheader
                 i_poh2 LIKE bapimepoheaderx
                 i_poi1 LIKE poi1[]
                 i_poi2 LIKE poi2[]
                 i_poi3 LIKE poi3[]
                 i_poi4 LIKE poi4[]
                 i_soh1 LIKE bapisdhd1
                 i_soi1 LIKE soi1[]
                 i_soi2 LIKE soi2[]
                 i_soi3 LIKE soi3[].

  DATA : i_poi_temp LIKE poi1 OCCURS 0 WITH HEADER LINE.

  IF v_bukrs = '8070' AND v_bsart = 'ZRL'.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = i_poh1
        poheaderx        = i_poh2
      IMPORTING
        exppurchaseorder = po_num
      TABLES
        return           = l_t_return
        poitem           = i_poi1
        poitemx          = i_poi2
        poschedule       = i_poi3
        poschedulex      = i_poi4.

    l_error_found = ' '.

    LOOP AT l_t_return.
      IF l_t_return-type  = 'E'.
        l_error_found = 'X'.
        WRITE : l_t_return-message, l_t_return-parameter,
                l_t_return-row.
      ENDIF.
    ENDLOOP.

    IF l_error_found <> 'X' AND so_flag = 'X'.
      soh1-purch_no_c = po_num.
      CLEAR l_t_return.
      REFRESH l_t_return.
      IF soh1-doc_type = 'ZOCW'.
        CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
          EXPORTING
            order_header_in       = i_soh1
            convert               = 'X'
*       TESTRUN                = 'X'
          IMPORTING
            salesdocument         = so_num
          TABLES
            return                = l_t_return
            order_items_in        = i_soi1
            order_partners        = i_soi2
            order_schedules_in    = i_soi3.
      ELSEIF soh1-doc_type = 'ZRCW'.
        CALL FUNCTION 'BAPI_CUSTOMERRETURN_CREATE'
          EXPORTING
            return_header_in      = i_soh1
            convert               = 'X'
*       TESTRUN                = 'X'
          IMPORTING
            salesdocument         = so_num
          TABLES
            return                = l_t_return
            return_items_in       = i_soi1
            return_partners       = i_soi2
            return_schedules_in   = i_soi3.
      ENDIF.
    ENDIF.

    LOOP AT l_t_return.
      IF l_t_return-type  = 'E'.
        l_error_found = 'X'.
        WRITE l_t_return-message.
      ENDIF.
    ENDLOOP.

    IF l_error_found = 'X'.
      ROLLBACK WORK.
    ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      COMMIT WORK AND WAIT.
      IF so_flag = 'X'.
        CONCATENATE 'PO/SO nomer :' po_num '/' so_num 'created' INTO txtmsg
        SEPARATED BY space.
      ELSE.
        CONCATENATE 'PO nomer :' po_num 'created' INTO txtmsg SEPARATED BY
       space.
      ENDIF.
      WRITE txtmsg.
    ENDIF.

  ELSE.

    APPEND LINES OF i_poi1 TO i_poi_temp.
    SORT i_poi_temp BY material.
    DELETE ADJACENT DUPLICATES FROM i_poi_temp COMPARING material.
    IF sy-subrc = 0.
      READ TABLE i_poi_temp INDEX 1.
      CONCATENATE 'Ada Material dobel di file upoad untuk plant'
      i_poi_temp-plant INTO txtmsg SEPARATED BY
      space.
      WRITE txtmsg.
    ELSE.
      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          poheader         = i_poh1
          poheaderx        = i_poh2
        IMPORTING
          exppurchaseorder = po_num
        TABLES
          return           = l_t_return
          poitem           = i_poi1
          poitemx          = i_poi2
          poschedule       = i_poi3
          poschedulex      = i_poi4.

      l_error_found = ' '.

      LOOP AT l_t_return.
        IF l_t_return-type  = 'E'.
          l_error_found = 'X'.
          WRITE : l_t_return-message, l_t_return-parameter,
                  l_t_return-row.
        ENDIF.
      ENDLOOP.

      IF l_error_found <> 'X' AND so_flag = 'X'.
        soh1-purch_no_c = po_num.
        CLEAR l_t_return.
        REFRESH l_t_return.
        IF soh1-doc_type = 'ZOCW'.
          CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
            EXPORTING
              order_header_in       = i_soh1
              convert               = 'X'
*       TESTRUN                = 'X'
            IMPORTING
              salesdocument         = so_num
            TABLES
              return                = l_t_return
              order_items_in        = i_soi1
              order_partners        = i_soi2
              order_schedules_in    = i_soi3.
        ELSEIF soh1-doc_type = 'ZRCW'.
          CALL FUNCTION 'BAPI_CUSTOMERRETURN_CREATE'
            EXPORTING
              return_header_in      = i_soh1
              convert               = 'X'
*       TESTRUN                = 'X'
            IMPORTING
              salesdocument         = so_num
            TABLES
              return                = l_t_return
              return_items_in       = i_soi1
              return_partners       = i_soi2
              return_schedules_in   = i_soi3.
        ENDIF.
      ENDIF.

      LOOP AT l_t_return.
        IF l_t_return-type  = 'E'.
          l_error_found = 'X'.
          WRITE l_t_return-message.
        ENDIF.
      ENDLOOP.

      IF l_error_found = 'X'.
        ROLLBACK WORK.
      ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        COMMIT WORK AND WAIT.
        IF so_flag = 'X'.
          CONCATENATE 'PO/SO nomer :' po_num '/' so_num 'created' INTO txtmsg
          SEPARATED BY space.
        ELSE.
          CONCATENATE 'PO nomer :' po_num 'created' INTO txtmsg SEPARATED BY
         space.
        ENDIF.
        WRITE txtmsg.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR   i_poh1.
  CLEAR   i_poh2.
  REFRESH i_poi1.
  REFRESH i_poi2.
  REFRESH i_poi3.
  REFRESH i_poi4.
  CLEAR   i_soh1.
  REFRESH i_soi1.
  REFRESH i_soi2.
  REFRESH i_soi3.
  CLEAR po_num.
  CLEAR so_num.
  CLEAR l_t_return.
  REFRESH l_t_return.
ENDFORM.                    " f_BAPI_process


*---------------------------------------------------------------------*
*       FORM f_BAPI_process2                                          *
*---------------------------------------------------------------------*
*      -->I_PRI1 LIKE PRI1[]
*---------------------------------------------------------------------*
FORM f_bapi_process2
          USING i_pri1 LIKE pri1[].

  DATA : i_pri_temp LIKE pri1 OCCURS 0 WITH HEADER LINE.

  APPEND LINES OF i_pri1 TO i_pri_temp.
  SORT i_pri_temp BY material.
  DELETE ADJACENT DUPLICATES FROM i_pri_temp COMPARING material plant.
  IF sy-subrc = 0.
    READ TABLE i_pri_temp INDEX 1.
    CONCATENATE 'Ada Material dobel di file upload untuk plant'
    i_pri_temp-plant INTO txtmsg SEPARATED BY
    space.
    WRITE txtmsg.
  ELSE.
    CALL FUNCTION 'BAPI_REQUISITION_CREATE'
      EXPORTING
        automatic_source  = ''
      IMPORTING
        number            = pr_num
      TABLES
        requisition_items = pri1
        return            = l_t_return2.


    LOOP AT l_t_return2.
      IF l_t_return2-type  = 'E'.
        l_error_found = 'X'.
        WRITE l_t_return2-message.
      ENDIF.
    ENDLOOP.

    IF l_error_found = 'X'.
      ROLLBACK WORK.
    ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      COMMIT WORK AND WAIT.
      CONCATENATE 'PR nomer :' pr_num 'created' INTO txtmsg SEPARATED BY
    space.
      WRITE txtmsg.
    ENDIF.
  ENDIF.
  REFRESH i_pri1.
  CLEAR l_t_return.
  REFRESH l_t_return.
ENDFORM.                    " f_BAPI_process2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_NB
*&---------------------------------------------------------------------*
FORM f_process_nb .
  DATA : lt_po  TYPE t_po_so OCCURS 0 WITH HEADER LINE.
  DATA : i_poh1 LIKE bapimepoheader,
         i_poh2 LIKE bapimepoheaderx,
         i_poi1 LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         i_poi2 LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
         i_poi3 LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
         i_poi4 LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE.

  DATA : lv_ebelp     LIKE ekpo-ebelp.

  lt_po[] = i_po_so[].
  SORT lt_po BY post.
  DELETE lt_po WHERE lifnr IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_po COMPARING post.

  LOOP AT lt_po.
    SELECT SINGLE bukrs FROM t001k INTO i_poh1-comp_code
    WHERE bwkey = lt_po-werks.

    CONCATENATE lt_po-bedat+6(4) lt_po-bedat+3(2) lt_po-bedat(2) INTO i_poh1-doc_date.
    i_poh1-creat_date  = sy-datum.
    CASE lt_po-bsart.
      WHEN 'ZO2O'.
        i_poh1-purch_org   = 'O2O'.
      WHEN OTHERS.
        i_poh1-purch_org   = 'SOM'.
    ENDCASE.
    i_poh1-pur_group   = lt_po-ekgrp.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lt_po-lifnr
      IMPORTING
        output = i_poh1-vendor.

    i_poh1-doc_type    = lt_po-bsart.

    i_poh2-comp_code   = 'X'.
    i_poh2-doc_date    = 'X'.
    i_poh2-creat_date  = 'X'.
    i_poh2-purch_org   = 'X'.
    i_poh2-pur_group   = 'X'.
    i_poh2-vendor      = 'X'.
    i_poh2-doc_type    = 'X'.

    lv_ebelp = '00010'.

    CLEAR : i_poi1[], i_poi1, i_poi2[], i_poi2,
            i_poi3[], i_poi3, i_poi4[], i_poi4.

    CASE lt_po-bsart.
      WHEN 'NB' OR 'ZO2O'.
        i_poh1-gr_message  = 'X'.
        i_poh2-gr_message  = 'X'.

      WHEN 'RNB' OR 'RZB'.
        i_poh1-reason_cancel = lt_po-absgr.
        i_poh2-reason_cancel = 'X'.
    ENDCASE.

    LOOP AT i_po_so INTO wa_po_so WHERE post = lt_po-post.
      i_poi1-po_item      = lv_ebelp.
      i_poi2-po_item      = lv_ebelp.
      i_poi2-material     = 'X'.
      i_poi1-material     = wa_po_so-matnr.
      i_poi2-material     = 'X'.
      i_poi1-quantity     = wa_po_so-menge.
      i_poi2-quantity     = 'X'.
      i_poi1-plant        = wa_po_so-werks.
      i_poi2-plant        = 'X'.
      i_poi1-stge_loc     = wa_po_so-lgort.
      i_poi2-stge_loc     = 'X'.

      i_poi3-po_item       = lv_ebelp.
      i_poi4-po_item       = lv_ebelp.

      CASE lt_po-bsart.
        WHEN 'NB' OR 'ZO2O'.
          i_poi1-order_reason = wa_po_so-bsgru.
          i_poi2-order_reason = 'X'.

          i_poi3-delivery_date = wa_po_so-eindt.
          i_poi4-delivery_date = 'X'.

        WHEN 'RNB' OR 'RZB'.
          i_poi1-ret_item      = 'X'.
          i_poi2-ret_item      = 'X'.
          CONCATENATE wa_po_so-eindt+6(4) wa_po_so-eindt+3(2) wa_po_so-eindt(2)
          INTO i_poi1-price_date.
          i_poi2-price_date    = 'X'.
          i_poi1-batch         = wa_po_so-charg.
          i_poi2-batch         = 'X'.
          i_poi1-trackingno    = wa_po_so-bednr.
          i_poi2-trackingno    = 'X'.
      ENDCASE.

      APPEND i_poi1.
      APPEND i_poi2.
      APPEND i_poi3.
      APPEND i_poi4.

      ADD 10 TO lv_ebelp.
    ENDLOOP.

    CLEAR : l_t_return, txtmsg.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = i_poh1
        poheaderx        = i_poh2
      IMPORTING
        exppurchaseorder = po_num
      TABLES
        return           = l_t_return
        poitem           = i_poi1
        poitemx          = i_poi2
        poschedule       = i_poi3
        poschedulex      = i_poi4.

    LOOP AT l_t_return.
      IF l_t_return-type  = 'E'.
        l_error_found = 'X'.
        WRITE : l_t_return-message, l_t_return-parameter, l_t_return-row.
      ENDIF.
    ENDLOOP.

    IF l_error_found = 'X'.
      ROLLBACK WORK.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      CONCATENATE 'PO nomer :' po_num 'created' INTO txtmsg
      SEPARATED BY space.
    ENDIF.
    WRITE txtmsg.
    WRITE : / sy-uline.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_NB

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data .
  DATA : lt_po   TYPE t_po_so OCCURS 0 WITH HEADER LINE,
         lt_po1  TYPE t_po_so OCCURS 0 WITH HEADER LINE,
         lv_lines   TYPE int4.

  lt_po[] = i_po_so[].
  SORT lt_po BY bsart lifnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_po COMPARING bsart.
  DELETE lt_po WHERE lifnr IS INITIAL.

  DESCRIBE TABLE lt_po LINES lv_lines.
  IF lv_lines > 1.
    MESSAGE s000(zab) WITH 'There is more than one Purchasing Document Type'
                      DISPLAY LIKE 'E'.
    l_error_found = 'X'.
  ELSE.
    READ TABLE lt_po INDEX 1.
    CASE 'X'.
      WHEN po_nb.
        IF lt_po-bsart NE 'NB'.
          MESSAGE s000(zab) WITH 'Purchasing Document Type should be NB'
                            DISPLAY LIKE 'E'.
          l_error_found = 'X'.
        ENDIF.
      WHEN po_o2o.
        IF lt_po-bsart NE 'ZO2O'.
          MESSAGE s000(zab) WITH 'Purchasing Document Type should be ZO2O'
                            DISPLAY LIKE 'E'.
          l_error_found = 'X'.
        ENDIF.
      WHEN po_rnb.
        IF lt_po-bsart NE 'RNB' AND
          lt_po-bsart NE 'RZB'.
          MESSAGE s000(zab) WITH 'Purchasing Document Type should be RNB or RZB'
                            DISPLAY LIKE 'E'.
          l_error_found = 'X'.
        ENDIF.
    ENDCASE.
  ENDIF.

  IF l_error_found IS INITIAL.
    CLEAR lv_lines.
    lt_po1[] = lt_po[] = i_po_so[].
    SORT lt_po BY post.
    DELETE ADJACENT DUPLICATES FROM lt_po COMPARING post.
    SORT lt_po1 BY post werks lgort.
    DELETE ADJACENT DUPLICATES FROM lt_po1 COMPARING post werks lgort.
    LOOP AT lt_po.
      CLEAR lv_lines.
      LOOP AT lt_po1 WHERE post = lt_po-post.
        ADD 1 TO lv_lines.
      ENDLOOP.
      IF lv_lines > 1.
        MESSAGE s000(zab) WITH 'There is more than one Plant or Storage Location'
                          DISPLAY LIKE 'E'.
        l_error_found = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CEK_QUANTITY
*&---------------------------------------------------------------------*
FORM f_cek_quantity  USING    fu_matnr fu_menge.

  DATA : lv_extwg   TYPE mara-extwg,
         lv_matkl   TYPE mara-matkl,
         lv_meins   TYPE mara-meins,
         lv_umrez   TYPE marm-umrez,
         lv_menge   TYPE ekpo-menge.

  DATA : ls_zt16fw  TYPE zt16fw.

  SELECT SINGLE meins matkl
    FROM mara
    INTO (lv_meins, lv_matkl)
    WHERE matnr = fu_matnr.

  lv_extwg  = lv_matkl(3).

  CLEAR ls_zt16fw.
  READ TABLE gt_zt16fw INTO ls_zt16fw WITH KEY extwg = lv_extwg.
  IF sy-subrc = 0.
    IF ls_zt16fw-meins IS NOT INITIAL.
      SELECT SINGLE umrez
        FROM marm
        INTO lv_umrez
        WHERE matnr = fu_matnr
          AND meinh = ls_zt16fw-meins.

      IF sy-subrc = 0.
        lv_menge = fu_menge MOD lv_umrez.
        IF lv_menge IS NOT INITIAL.
          MESSAGE e002(zz) WITH 'Quantity kurang per' ls_zt16fw-meins.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CEK_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PR_PO_STO
*&---------------------------------------------------------------------*
FORM f_get_data_pr_po_sto .
  SELECT banfn bnfpo loekz ekgrp matnr werks lgort afnam menge meins
    ebakz ebeln
    FROM eban
    INTO CORRESPONDING FIELDS OF TABLE gt_eban
    WHERE banfn IN so_banfn
      AND badat IN so_badat
      AND werks IN so_werks
      AND lgort IN so_lgort
      AND bsart = 'ZPR'
      AND banpr = '05'.
ENDFORM.                    " F_GET_DATA_PR_PO_STO

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN prpo_sto.
      IF so_badat[] IS INITIAL.
        PERFORM f_screen_error USING 'BAD'.
      ENDIF.
    WHEN p_chgpr.
      IF p_finm1 IS INITIAL.
        PERFORM f_screen_error USING 'FI1'.
      ENDIF.
    WHEN p_chgdn.
      IF p_finm2 IS INITIAL.
        PERFORM f_screen_error USING 'FI2'.
      ENDIF.
    WHEN OTHERS.
      IF file_i IS INITIAL.
        PERFORM f_screen_error USING 'FIL'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN prpo_sto.
      PERFORM f_modify_screen USING : 'FIL' '0' '',
                                      'FI1' '' '0',
                                      'FI2' '' '0'.
      CLEAR : p_finm1, p_finm2.
    WHEN p_chgpr.
      PERFORM f_modify_screen USING : 'BAN' '0' '',
                                      'BAD' '0' '',
                                      'WER' '0' '',
                                      'LGO' '0' '',
                                      'FIL' '' '0',
                                      'FI2' '' '0'.
      CLEAR : file_i, p_finm2.
    WHEN p_chgdn.
      PERFORM f_modify_screen USING : 'BAN' '0' '',
                                      'BAD' '0' '',
                                      'WER' '0' '',
                                      'LGO' '0' '',
                                      'FIL' '' '0',
                                      'FI1' '' '0'.
      CLEAR : file_i, p_finm1.
    WHEN OTHERS.
      PERFORM f_modify_screen USING : 'BAN' '0' '',
                                      'BAD' '0' '',
                                      'WER' '0' '',
                                      'LGO' '0' '',
                                      'FI1' '' '0',
                                      'FI2' '' '0'.
      CLEAR : p_finm1, p_finm2.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PR_PO_STO
*&---------------------------------------------------------------------*
FORM f_process_pr_po_sto .
  DATA : ls_eban     TYPE eban,
         lt_out      LIKE eban OCCURS 0 WITH HEADER LINE,
         lt_ekpo     LIKE ekpo OCCURS 0 WITH HEADER LINE,
         ls_out      LIKE gt_out.

  SORT gt_eban BY banfn.
  lt_out[] = gt_out[] = gt_eban[].
  DELETE ADJACENT DUPLICATES FROM gt_out COMPARING banfn.

  SORT lt_out BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING ebeln.

  IF lt_out[] IS NOT INITIAL.
    SELECT ebeln bednr
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
      FOR ALL ENTRIES IN lt_out
      WHERE ebeln = lt_out-ebeln.
  ENDIF.

  LOOP AT gt_out INTO ls_out.
    READ TABLE gt_eban INTO ls_eban WITH KEY banfn = ls_eban-banfn
                                             loekz = 'X'.
    IF sy-subrc = 0.
      DELETE gt_eban WHERE banfn = ls_eban-banfn.
      DELETE gt_out.
      CONTINUE.
    ENDIF.

    IF ls_out-ebakz IS INITIAL.
      CLEAR ls_out-ebeln.
      MODIFY gt_out FROM ls_out TRANSPORTING ebeln.
      CONTINUE.
    ENDIF.

    READ TABLE lt_ekpo WITH KEY ebeln = ls_out-ebeln.
    IF sy-subrc = 0.
      ls_out-bednr  = lt_ekpo-bednr.
      MODIFY gt_out FROM ls_out TRANSPORTING bednr.
    ENDIF.
    CLEAR ls_out.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_PR_PO_STO

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CALL SCREEN 100.
ENDFORM.                    " F_PRINT_DATA

INCLUDE zmm_po_so_upload_f01.
