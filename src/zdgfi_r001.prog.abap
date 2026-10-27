*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : RFI-24
*& Title                 : Cash Flow Report
*& Functional Designer   : Mourme Taruna Halim / Yanty Siwan
*& ABAP Developer        : Samanta Limbrada / Tiara Astari
*& Initial Creation Date : 09.08.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& Laporan ini diperlukan sebagai salah satu report eksternal yang harus diterbitkan
*& oleh perusahaan. Isinya adalah tentang arus masuk dan keluar saldo kas & setara
*& kas perusahaan yang digunakan/berasal dari 3 aktivitas, yaitu aktivitas operasi,
*& investasi dan pendanaan
*&
*& Logical DB : N/A
*&
*& Assumption : N/A
*&
*&----------------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&----------------------------------------------------------------------------*
*& Date        By        TR#          Version  Description
*&----------------------------------------------------------------------------*
*& 09.08.2012  SAP_DEV02 DEVK932230   01       Initial creation
*& 05.10.2012  SAP_DEV02 DEVK932872   02       Refine logic, change report layout
*& 10.10.2012  SAP_DEV02 DEVK933212   03       Include reversed documents
*& 30.10.2012  SAP_DEV02 DEVK933640   04       -Fix indentation bug
*&                                             -Fix many-to-many documents
*&                                              (many cash to many expense)
*&                                             -Display Vendor/Customer Name for
*&                                              One Time Vendor/Customer
*& 20.12.2012  SAP_DEV02 DEVK934544   05       1.Update Logic in proportionate & conversion gain loss
*&                                               (flipped logic, switch into correct condition)
*&                                             2.Sort itab before binary search.
*& 22.12.2012  SAP_DEV02 -            06        1.Changes for case where there are unmapped gl which contains clearing document
*&                                               This causes conflict when displaying report &
*&                                               calculate proportionate amount.
*& 26.12.2012  SAP_DEV02 DEVK934552   07       Correct Advance Payment Scenario
*& 11.04.2013  SAP_DEV02 DEVK935203   08       Major changes in core logic to
*&                                             get flow of documents
*& 12.04.2013  SAP_DEV02 DEVK932521   09       Combine multiple cash item in one document to one line
*& 26.09.2013  SAP_DEV02 DEVK936346   10       Only get BKPF data with xreversal EQ space
*&----------------------------------------------------------------------------*
REPORT  zdgfi_r001.


*-----------------------------------------------------------------------------*
* T A B L E S
*-----------------------------------------------------------------------------*
TABLES: bseg, bkpf, sscrfields.

INCLUDE <icon>.

*-----------------------------------------------------------------------------*
* T Y P E S
*-----------------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: BEGIN OF ty_bseg,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         hkont TYPE bseg-hkont,
         buzei TYPE bseg-buzei,
         augbl TYPE bseg-augbl,
         augdt TYPE bseg-augdt,
         bschl TYPE bseg-bschl,
         shkzg TYPE bseg-shkzg,
         dmbtr TYPE netwr,
         sgtxt TYPE bseg-sgtxt,
         zuonr TYPE bseg-zuonr,
         umskz TYPE bseg-umskz,
         wrbtr TYPE bseg-wrbtr,
         vbund TYPE bseg-vbund,
         lifnr TYPE bseg-lifnr,
         kunnr TYPE bseg-kunnr,
         prctr TYPE bseg-prctr,
       END OF ty_bseg,

       BEGIN OF ty_bsec,
         bukrs TYPE bsec-bukrs,
         belnr TYPE bsec-belnr,
         gjahr TYPE bsec-gjahr,
         buzei TYPE bsec-buzei,
         name1 TYPE bsec-name1,
       END OF ty_bsec,

       BEGIN OF ty_cash_expense,
         bukrs_bank TYPE bseg-bukrs,
         belnr_bank TYPE bseg-belnr,
         gjahr_bank TYPE bseg-gjahr,
         buzei_bank TYPE bseg-buzei,
         shkzg_bank TYPE bseg-shkzg,
         dmbtr_bank TYPE bseg-dmbtr,
         bukrs      TYPE bseg-bukrs,
         belnr      TYPE bseg-belnr,
         gjahr      TYPE bseg-gjahr,
         buzei      TYPE bseg-buzei,
         shkzg      TYPE bseg-shkzg,
         dmbtr      TYPE bseg-dmbtr,
         augbl      TYPE bseg-augbl,
         hkont      TYPE bseg-hkont,
         cf_amount  TYPE bseg-dmbtr,
         lifnr      TYPE bseg-lifnr,
         kunnr      TYPE bseg-kunnr,
         step       TYPE char1,
       END OF ty_cash_expense,

       BEGIN OF ty_expense,
         bukrs      TYPE bseg-bukrs,
         belnr      TYPE bseg-belnr,
         gjahr      TYPE bseg-gjahr,
         buzei      TYPE bseg-buzei,
         dmbtr      TYPE bseg-dmbtr,
         total_cash TYPE bseg-dmbtr,
         total_exp  TYPE bseg-dmbtr,
       END OF ty_expense,

       BEGIN OF ty_cash,
         bukrs     TYPE bseg-bukrs,
         belnr     TYPE bseg-belnr,
         gjahr     TYPE bseg-gjahr,
         buzei     TYPE bseg-buzei,
         dmbtr     TYPE bseg-dmbtr,
         total_exp TYPE bseg-dmbtr,
       END OF ty_cash,

       BEGIN OF ty_bkpf,
         bukrs     TYPE bkpf-bukrs,
         belnr     TYPE bkpf-belnr,
         gjahr     TYPE bkpf-gjahr,
         blart     TYPE bkpf-blart,
         budat     TYPE bkpf-budat,
         monat     TYPE bkpf-monat,
         waers     TYPE bkpf-waers,
         stblg     TYPE bkpf-stblg,
         awkey     TYPE bkpf-awkey,
         xreversal TYPE bkpf-xreversal,
       END OF ty_bkpf,

       BEGIN OF ty_bsas,
         bukrs TYPE bsas-bukrs,
         hkont TYPE bsas-hkont,
         augdt TYPE bsas-augdt,
         augbl TYPE bsas-augbl,
         zuonr TYPE bsas-zuonr,
         gjahr TYPE bsas-gjahr,
         belnr TYPE bsas-belnr,
         buzei TYPE bsas-buzei,
       END OF ty_bsas,

       BEGIN OF ty_ska1,
         ktopl TYPE ska1-ktopl,
         saknr TYPE ska1-saknr,
         sakan TYPE ska1-sakan,
         ktoks TYPE ska1-ktoks,
       END OF ty_ska1,

       BEGIN OF ty_glt0,
         bukrs TYPE glt0-bukrs,
         ryear TYPE glt0-ryear,
         racct TYPE glt0-racct,
         rbusa TYPE glt0-rbusa,
         rtcur TYPE glt0-rtcur,
         drcrk TYPE glt0-drcrk,
         rpmax TYPE glt0-rpmax,
         hslvt TYPE glt0-hslvt,
         hsl01 TYPE glt0-hsl01,
         hsl02 TYPE glt0-hsl02,
         hsl03 TYPE glt0-hsl03,
         hsl04 TYPE glt0-hsl04,
         hsl05 TYPE glt0-hsl05,
         hsl06 TYPE glt0-hsl06,
         hsl07 TYPE glt0-hsl07,
         hsl08 TYPE glt0-hsl08,
         hsl09 TYPE glt0-hsl09,
         hsl10 TYPE glt0-hsl10,
         hsl11 TYPE glt0-hsl11,
         hsl12 TYPE glt0-hsl12,
         hsl13 TYPE glt0-hsl13,
         hsl14 TYPE glt0-hsl14,
         hsl15 TYPE glt0-hsl15,
         hsl16 TYPE glt0-hsl16,
       END OF ty_glt0,

       BEGIN OF ty_cf_item.
         INCLUDE STRUCTURE zdgfidt004.
         TYPES:   monat TYPE monat,
         cf01  TYPE dmbtr,
         cf02  TYPE dmbtr,
         cf03  TYPE dmbtr,
         cf04  TYPE dmbtr,
         cf05  TYPE dmbtr,
         cf06  TYPE dmbtr,
         cf07  TYPE dmbtr,
         cf08  TYPE dmbtr,
         cf09  TYPE dmbtr,
         cf10  TYPE dmbtr,
         cf11  TYPE dmbtr,
         cf12  TYPE dmbtr,
       END OF ty_cf_item,

       BEGIN OF ty_lfa1,
         lifnr TYPE lfa1-lifnr,
         name1 TYPE lfa1-name1,
       END OF ty_lfa1,

       BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
       END OF ty_kna1,

       ty_bseg_tab TYPE STANDARD TABLE OF ty_bseg,
       ty_bsas_tab TYPE STANDARD TABLE OF ty_bsas,
       ty_bkpf_tab TYPE STANDARD TABLE OF ty_bkpf.


*-----------------------------------------------------------------------------*
* I N T E R N A L   T A B L E S   &   W O R K I N G - A R E A S
*-----------------------------------------------------------------------------*
DATA: gs_stmt         TYPE zdgfidt003,
      gt_cf_item      TYPE STANDARD TABLE OF ty_cf_item,
      wa_cf_item      TYPE ty_cf_item,
      gt_gl_map       TYPE STANDARD TABLE OF zdgfidt005,
      wa_gl_map       TYPE zdgfidt005,
      gt_bseg         TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_1       TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_2       TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_3       TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_4       TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_5       TYPE STANDARD TABLE OF ty_bseg,
      gt_bseg_x       TYPE STANDARD TABLE OF ty_bseg,
      wa_bseg         TYPE ty_bseg,
      wa_bseg_1       TYPE ty_bseg,
      wa_bseg_2       TYPE ty_bseg,
      wa_bseg_3       TYPE ty_bseg,
      wa_bseg_4       TYPE ty_bseg,
      wa_bseg_5       TYPE ty_bseg,
      gt_bsec         TYPE STANDARD TABLE OF ty_bsec,
      wa_bsec         TYPE ty_bsec,
      gt_bsas         TYPE STANDARD TABLE OF ty_bsas,
      gt_bsas_1       TYPE STANDARD TABLE OF ty_bsas,
      gt_bsas_2       TYPE STANDARD TABLE OF ty_bsas,
      gt_bsas_3       TYPE STANDARD TABLE OF ty_bsas,
      gt_bsas_4       TYPE STANDARD TABLE OF ty_bsas,
      wa_bsas         TYPE ty_bsas,
      wa_bsas_1       TYPE ty_bsas,
      wa_bsas_2       TYPE ty_bsas,
      wa_bsas_3       TYPE ty_bsas,
      wa_bsas_4       TYPE ty_bsas,
      wa_bsas_5       TYPE ty_bsas,
      gt_bkpf         TYPE STANDARD TABLE OF ty_bkpf,
      wa_bkpf         TYPE ty_bkpf,
      gt_bkpf_x       TYPE STANDARD TABLE OF ty_bkpf,
      gt_ska1         TYPE STANDARD TABLE OF ty_ska1,
      wa_ska1         TYPE ty_ska1,
      gt_glt0         TYPE STANDARD TABLE OF ty_glt0,
      wa_glt0         TYPE ty_glt0,
      gt_skat         TYPE STANDARD TABLE OF skat,
      gt_skat_x       TYPE STANDARD TABLE OF skat,
      wa_skat         TYPE skat,
      gt_lfa1         TYPE STANDARD TABLE OF ty_lfa1,
      wa_lfa1         TYPE ty_lfa1,
      gt_kna1         TYPE STANDARD TABLE OF ty_kna1,
      wa_kna1         TYPE ty_kna1,
      gt_cash_expense TYPE SORTED TABLE OF ty_cash_expense WITH UNIQUE KEY bukrs
                                                                           belnr
                                                                           gjahr
                                                                           buzei
                                                                           bukrs_bank
                                                                           belnr_bank
                                                                           gjahr_bank
                                                                           buzei_bank,
      wa_cash_expense TYPE ty_cash_expense,
      gt_expense      TYPE SORTED TABLE OF ty_expense WITH UNIQUE KEY bukrs belnr gjahr buzei,
      wa_expense      TYPE ty_expense,
      gt_cash         TYPE SORTED TABLE OF ty_cash WITH UNIQUE KEY bukrs belnr gjahr buzei,
      wa_cash         TYPE ty_cash,
      gt_setleaf      TYPE STANDARD TABLE OF setleaf,
      wa_setleaf      TYPE setleaf,
      gv_tabix        LIKE sy-tabix.

* For ALV
DATA: gv_layout   TYPE slis_layout_alv,
      gt_sorttab  TYPE slis_t_sortinfo_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gt_heading  TYPE slis_t_listheader,
      gt_events   TYPE slis_t_event,
      gt_report   TYPE STANDARD TABLE OF zdgstfi_cash_flow_header,
      wa_report   TYPE zdgstfi_cash_flow_header,
      gt_detail   TYPE SORTED TABLE OF zdgstfi_cash_flow_item WITH UNIQUE KEY belnr buzei ibelnr ibuzei igjahr,
      wa_detail   TYPE zdgstfi_cash_flow_item,
      gt_selected TYPE STANDARD TABLE OF zdgstfi_cash_flow_item,
      gv_repid    TYPE sy-repid,
      gv_monat    TYPE monat,
      gv_msg(500).


FIELD-SYMBOLS:  <fs_bkpf> TYPE ty_bkpf.


*-----------------------------------------------------------------------------*
* G L O B A L   V A R I A B L E S
*-----------------------------------------------------------------------------*
DATA: gv_local_curr TYPE waers.


*-----------------------------------------------------------------------------*
* R A N G E S
*-----------------------------------------------------------------------------*
DATA:
  r_monat       TYPE RANGE OF monat,
  wa_r_monat    LIKE LINE OF r_monat,
  r_gl_cash     TYPE RANGE OF hkont,
  wa_r_gl       LIKE LINE OF r_gl_cash,
  r_gainloss    TYPE RANGE OF hkont,
  wa_r_gainloss LIKE LINE OF r_gainloss.


*-----------------------------------------------------------------------
* C O N S T A N T S
*-----------------------------------------------------------------------
CONSTANTS: gc_double_click TYPE gui_code   VALUE '&IC1', "FCODE for Double click
           gc_show_invoice TYPE gui_code   VALUE '&INV',
           gc_unmapped     TYPE zde_strow  VALUE '800000',
           gc_beginning    TYPE zde_strow  VALUE '000001',
           gc_ending       TYPE zde_strow  VALUE '900000',
           gc_beginning_t  TYPE char50     VALUE 'BEGINNING BALANCE'.


CONTROLS : tc_007          TYPE TABLEVIEW USING SCREEN 100.

DATA : lines   TYPE i,
       fill    TYPE i,
       ok_code TYPE sy-ucomm.

TYPES : BEGIN OF ty_xbkpf,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
          monat TYPE bkpf-monat,
          waers TYPE bkpf-waers,
        END OF ty_xbkpf.

TYPES : BEGIN OF ty_xbseg,
          bukrs TYPE bseg-bukrs,
          belnr TYPE bseg-belnr,
          gjahr TYPE bseg-gjahr,
          buzei TYPE bseg-buzei,
          augdt TYPE bseg-augdt,
          shkzg TYPE bseg-shkzg,
          gsber TYPE bseg-gsber,
          dmbtr TYPE bseg-dmbtr,
          wrbtr TYPE bseg-wrbtr,
          sgtxt TYPE bseg-sgtxt,
          hkont TYPE bseg-hkont,
        END OF ty_xbseg.

TYPES : BEGIN OF ty_skb1,
          bukrs TYPE skb1-bukrs,
          saknr TYPE skb1-saknr,
        END OF ty_skb1.

TYPES : BEGIN OF ty_007.
          INCLUDE STRUCTURE zdgfidt007.
          TYPES :   wrbtr    TYPE bseg-wrbtr,
          mark,
          statu(4),
        END OF ty_007.

DATA : gt_007 TYPE STANDARD TABLE OF ty_007,
       gs_007 LIKE LINE OF gt_007.

DATA : gt_skb1    TYPE STANDARD TABLE OF ty_skb1.

DATA : gv_butxt TYPE t001-butxt,
       gv_gtext TYPE tgsbt-gtext.

TYPES : ty_xbkpf_tab TYPE STANDARD TABLE OF ty_xbkpf,
        ty_xbseg_tab TYPE STANDARD TABLE OF ty_xbseg.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

*-----------------------------------------------------------------------------*
* S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_versn TYPE zdgfidt003-versn OBLIGATORY MODIF ID pve,
  p_bukrs TYPE bkpf-bukrs OBLIGATORY MODIF ID pbu,
  p_gsber TYPE bseg-gsber OBLIGATORY MODIF ID pgs,
  p_gjahr TYPE bkpf-gjahr OBLIGATORY MODIF ID pgj,
  p_augdt TYPE bseg-augdt NO-DISPLAY MODIF ID pau,
  p_monat TYPE bkpf-monat OBLIGATORY MODIF ID pmo.
SELECT-OPTIONS:
  so_belnr FOR bseg-belnr MODIF ID sbe.
*  so_gsber FOR bseg-gsber NO INTERVALS.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 900 AS WINDOW TITLE TEXT-003.
SELECT-OPTIONS so_beln1   FOR bseg-belnr NO INTERVALS
                                         OBLIGATORY.
PARAMETER pa_gjahr  TYPE bkpf-gjahr OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 900.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.


*-----------------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*-----------------------------------------------------------------------------*
INITIALIZATION.



*-----------------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_versn.
  PERFORM f_f4_versn USING 'P_VERSN'.


*-----------------------------------------------------------------------------*
* S T A RT - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_progres USING 'prepare get data...'.

* Get Local Currency
      PERFORM f_get_local_currency.

* Get Statement Version, Cash Flow Item, and G/L Mapping Data from
* ZDGFIDT003, ZDGFIDT004, and ZDGFIDT005
      PERFORM f_get_statement_version.

* Get List of G/L Account Cash based on certain Account Group
      PERFORM f_get_gl_acc_cash.

* Populate Period (from 01 until Period in Sel Screen)
      PERFORM f_populate_period.

      CLEAR: gt_report[], gt_detail[].

* Get Total Transactions per Period and Balance Carryforward from GLT0
      PERFORM f_get_total_transactions.

* Populate Begining Balance from GLT0 (Beginning Balance for January is taken from
* Balance Carryforward)
      PERFORM f_populate_beginning_balance.

* CREATE CASH FLOW REPORT FOR EACH MONTH
* THIS IS TO PREVENT THE CASH FLOW FROM MOVING FROM MONTH TO MONTH
* HAVE TO BE SEPARATELY PROCESSED.
      LOOP AT r_monat INTO wa_r_monat.


        gv_monat = wa_r_monat-low.

        CLEAR gv_msg.
        CONCATENATE `get data for month ` gv_monat
               INTO gv_msg.
        PERFORM f_progres USING gv_msg.

*   Max Clearing Date is last date of the month
        PERFORM f_determine_clearing_date USING gv_monat.

*   Get Cash/Bank Documents, then Get all the Payment Usage
        PERFORM f_get_documents.

*   For 'Many Cash to One Expense' scenario, we have to re-calculate the expense amount
*   with pro-rate logic
        PERFORM f_calculate_pro_rate_amount.

*   Put docs to report
        PERFORM f_populate_report.

      ENDLOOP.

    WHEN radio2.
* Get Local Currency
      PERFORM f_get_local_currency.
      PERFORM f_get_data.
      CALL SCREEN 100.
  ENDCASE.

*-----------------------------------------------------------------------------*
* E N D - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
END-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_progres USING 'prepare display data...'.

* Populate Cash Flow Item
      PERFORM f_populate_cash_flow_item.

* Add Beginning Balance to Ending Balance
      PERFORM f_add_beginning_to_ending.

* Accumulate Year To Date (until the Period in Selection Screen)
      PERFORM f_accumulate_ytd.

* Indentation
      PERFORM f_manage_indentation.

* Display report
      PERFORM f_display_alv.

    WHEN radio2.
  ENDCASE.



*-----------------------------------------------------------------------------*
* S U B - R O U T I N E S
*-----------------------------------------------------------------------------*


FORM f_get_local_currency.

  CLEAR gv_local_curr.
  SELECT SINGLE waers
           FROM t001
           INTO gv_local_curr
          WHERE bukrs = p_bukrs.

ENDFORM.                    "f_get_local_currency


*&---------------------------------------------------------------------*
*&      Form  f_determine_clearing_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MONAT      text
*----------------------------------------------------------------------*
FORM f_determine_clearing_date USING monat TYPE monat.

  DATA: lv_date TYPE sy-datum.

* Populate 1st date of month
  CLEAR lv_date.
  CONCATENATE p_gjahr
              monat
              '01'
         INTO lv_date.

* Get last date of month
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_date
    IMPORTING
      last_day_of_month = p_augdt
*   EXCEPTIONS
*     DAY_IN_NO_DATE    = 1
*     OTHERS            = 2
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "f_determine_clearing_date


*&---------------------------------------------------------------------*
*&      Form  f_get_statement_version
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_statement_version.

* Get Statement Version
  CLEAR gs_stmt.
  SELECT SINGLE *
           FROM zdgfidt003
           INTO gs_stmt
          WHERE versn = p_versn.
  IF sy-subrc NE 0.
    MESSAGE s017(zfi) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* Get Statement Items
  CLEAR gt_cf_item[].
  SELECT *
    FROM zdgfidt004
    INTO TABLE gt_cf_item
   WHERE versn = p_versn.
  IF sy-subrc NE 0.
    MESSAGE s017(zfi) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* Get G/L Account Mapping
  CLEAR gt_gl_map[].
  SELECT *
    FROM zdgfidt005
    INTO TABLE gt_gl_map
   WHERE versn = p_versn.
  IF sy-subrc NE 0.
    MESSAGE s017(zfi) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  SORT gt_gl_map BY hkont shkzg.

* Add 'Unmapped Items'
  CLEAR wa_cf_item.
  wa_cf_item-strow  = gc_unmapped.
  wa_cf_item-parent = gc_ending.
  wa_cf_item-text   = 'Unmapped Items'.
  APPEND wa_cf_item TO gt_cf_item.

ENDFORM.                    "f_get_statement_version


*&---------------------------------------------------------------------*
*&      Form  f_get_gl_acc_cash
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_gl_acc_cash.

  DATA: lt_gl_cash  TYPE STANDARD TABLE OF zdgfidt006,
        lwa_gl_cash TYPE zdgfidt006.

* Get Account Group for GL Cash
  CLEAR lt_gl_cash[].
  SELECT *
    FROM zdgfidt006
    INTO TABLE lt_gl_cash.
  IF sy-subrc NE 0.
*   Account Group for GL Cash/Bank has not been maintained.
    MESSAGE s018(zfi) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CLEAR r_gl_cash[].
  LOOP AT lt_gl_cash INTO lwa_gl_cash.
    CLEAR wa_r_gl.
    wa_r_gl-sign   = 'I'.
    wa_r_gl-option = 'EQ'.
    wa_r_gl-low    = lwa_gl_cash-hkont.
    APPEND wa_r_gl TO r_gl_cash.
  ENDLOOP.

* Get G/L Conversion Gain/Loss from Set GL_ACCOUNT_GAIN/LOSS
  CLEAR gt_setleaf[].
  SELECT *
    FROM setleaf
    INTO TABLE gt_setleaf
   WHERE setname = 'GL_ACCOUNT_GAIN/LOSS'.

* Create Range for GL Account Conversion Gain/Loss
  CLEAR r_gainloss[].
  LOOP AT gt_setleaf INTO wa_setleaf.
    CLEAR wa_r_gainloss.
    wa_r_gainloss-sign   = wa_setleaf-valsign.
    wa_r_gainloss-option = wa_setleaf-valoption.
    wa_r_gainloss-low    = wa_setleaf-valfrom.
    wa_r_gainloss-high   = wa_setleaf-valto.
    APPEND wa_r_gainloss TO r_gainloss.
  ENDLOOP.

ENDFORM.                    "f_get_gl_acc_cash


*&---------------------------------------------------------------------*
*&      Form  f_populate_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_period.

  DATA: lv_period(2) TYPE n.

  lv_period = '01'.
  CLEAR r_monat[].

* Populate Range MONAT (Period)
  WHILE lv_period <= p_monat.
    CLEAR wa_r_monat.
    wa_r_monat-sign = 'I'.
    wa_r_monat-option = 'EQ'.
    wa_r_monat-low = lv_period.
    APPEND wa_r_monat TO r_monat.
    ADD 1 TO lv_period.
  ENDWHILE.

ENDFORM.                    "f_populate_period

*&---------------------------------------------------------------------*
*&      Form  f_get_documents
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_documents.

  CLEAR: gt_bseg[], gt_bseg_1[], gt_bseg_2[], gt_bseg_3[], gt_bseg_4[], gt_bseg_5[],
         gt_bkpf[], gt_bsas_1[], gt_bsas_2[], gt_bsas_3[], gt_bsas_4[].

* Gather all item in one internal table
  REFRESH gt_bseg[].
  REFRESH gt_cash_expense[].

* Get Cash (Bank In/Bank Out) Documents
  PERFORM f_get_cash_document.
  APPEND LINES OF gt_bseg_1 TO gt_bseg.

* Get Subsequent Documents
  PERFORM f_get_next_document USING    '2'
                              CHANGING gt_bseg_1
                                       gt_bseg_2
                                       gt_bsas_1.
  APPEND LINES OF gt_bseg_2 TO gt_bseg.

* Get Subsequent Documents
  PERFORM f_get_next_document USING    '3'
                              CHANGING gt_bseg_2
                                       gt_bseg_3
                                       gt_bsas_2.
  APPEND LINES OF gt_bseg_3 TO gt_bseg.

* Get Subsequent Documents
  PERFORM f_get_next_document USING    '4'
                              CHANGING gt_bseg_3
                                       gt_bseg_4
                                       gt_bsas_3.
  APPEND LINES OF gt_bseg_4 TO gt_bseg.

* Get Subsequent Documents
  PERFORM f_get_next_document USING    '5'
                              CHANGING gt_bseg_4
                                       gt_bseg_5
                                       gt_bsas_4.
  APPEND LINES OF gt_bseg_5 TO gt_bseg.

  PERFORM f_get_adjustment_document USING 'X'.

* Delete
  PERFORM f_delete_remaining_clear_doc.

* Get document header for all items above
  PERFORM f_get_all_doc_header.

* Get Customer and Vendor Name
  PERFORM f_get_customer_vendor.

ENDFORM.                    "f_get_documents


*&---------------------------------------------------------------------*
*&      Form  f_get_customer_vendor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_customer_vendor.

  CHECK gt_bseg[] IS NOT INITIAL.

* Get Vendor Name
  CLEAR gt_lfa1[].
  SELECT lifnr
         name1
    FROM lfa1
    INTO TABLE gt_lfa1
     FOR ALL ENTRIES IN gt_bseg
   WHERE lifnr = gt_bseg-lifnr.
  SORT gt_lfa1 BY lifnr.

* Get Customer Name
  CLEAR gt_kna1[].
  SELECT kunnr
         name1
    FROM kna1
    INTO TABLE gt_kna1
     FOR ALL ENTRIES IN gt_bseg
   WHERE kunnr = gt_bseg-kunnr.
  SORT gt_kna1 BY kunnr.

* Get One Time Vendor/Customer
  CLEAR gt_bsec[].
  SELECT bukrs
         belnr
         gjahr
         buzei
         name1
    FROM bsec
    INTO TABLE gt_bsec
    FOR ALL ENTRIES IN gt_bseg
    WHERE bukrs EQ gt_bseg-bukrs
    AND   belnr EQ gt_bseg-belnr
    AND   gjahr EQ gt_bseg-gjahr.
  SORT gt_bsec BY bukrs belnr gjahr buzei.

ENDFORM.                    "f_get_customer_vendor


*&---------------------------------------------------------------------*
*&      Form  f_delete_remaining_clear_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_delete_remaining_clear_doc.

  FIELD-SYMBOLS: <lfs_bseg> TYPE ty_bseg,
                 <lfs_ce>   TYPE ty_cash_expense.
  DATA: lt_cash_expense TYPE STANDARD TABLE OF ty_cash_expense,
        lv_index        TYPE sy-tabix,
        lv_max_step     TYPE char1.

* Delete all Clearing Document from Step 5
  LOOP AT gt_bseg_5 ASSIGNING <lfs_bseg> WHERE augbl IS NOT INITIAL.

    READ TABLE gt_bsas TRANSPORTING NO FIELDS WITH KEY augdt = <lfs_bseg>-augdt
                                                       augbl = <lfs_bseg>-augbl
                                                       BINARY SEARCH.
    IF sy-subrc NE 0.

      CLEAR <lfs_bseg>-augdt.
      CLEAR <lfs_bseg>-augbl.

      CLEAR wa_cash_expense.
      CLEAR wa_cash_expense-augbl.
      MODIFY gt_cash_expense FROM wa_cash_expense
                     TRANSPORTING augbl
                            WHERE bukrs = <lfs_bseg>-bukrs
                              AND belnr = <lfs_bseg>-belnr
                              AND gjahr = <lfs_bseg>-gjahr
                              AND buzei = <lfs_bseg>-buzei.

    ENDIF.

  ENDLOOP.

  CLEAR lt_cash_expense[].
  lt_cash_expense[] = gt_cash_expense[].
  SORT lt_cash_expense BY bukrs_bank belnr_bank gjahr_bank augbl.

* Delete Clearing Document of the Last Expenses of a Cash
* This is to make sure that all Cash Item will be displayed in the report
  LOOP AT gt_bseg_1 ASSIGNING <lfs_bseg> WHERE hkont IN r_gl_cash.

*   Find Expense (with Clearing Doc = blank) for this Cash Item
    READ TABLE lt_cash_expense TRANSPORTING NO FIELDS WITH KEY bukrs_bank = <lfs_bseg>-bukrs
                                                               belnr_bank = <lfs_bseg>-belnr
                                                               gjahr_bank = <lfs_bseg>-gjahr
                                                               augbl = ''
                                                               BINARY SEARCH.
    IF sy-subrc NE 0.
*     IF not found, determine Last Step
      READ TABLE lt_cash_expense INTO wa_cash_expense WITH KEY bukrs_bank = <lfs_bseg>-bukrs
                                                               belnr_bank = <lfs_bseg>-belnr
                                                               gjahr_bank = <lfs_bseg>-gjahr
                                                               BINARY SEARCH.
      IF sy-subrc = 0.
        lv_index = sy-tabix.
        CLEAR lv_max_step.
        LOOP AT lt_cash_expense INTO wa_cash_expense FROM lv_index.
          IF wa_cash_expense-bukrs_bank NE <lfs_bseg>-bukrs
          OR wa_cash_expense-belnr_bank NE <lfs_bseg>-belnr
          OR wa_cash_expense-gjahr_bank NE <lfs_bseg>-gjahr.
            EXIT.
          ENDIF.
          IF wa_cash_expense-step > lv_max_step.
            lv_max_step = wa_cash_expense-step.
          ENDIF.
        ENDLOOP.
*       Delete the Clearing Document from GT_CASH_EXPENSE and GT_BSEG_#
        LOOP AT gt_cash_expense ASSIGNING <lfs_ce> WHERE bukrs_bank = <lfs_bseg>-bukrs
                                                     AND belnr_bank = <lfs_bseg>-belnr
                                                     AND gjahr_bank = <lfs_bseg>-gjahr
                                                     AND step = lv_max_step.
          CLEAR <lfs_ce>-augbl.
          CASE lv_max_step.
            WHEN '1'.
              PERFORM f_delete_augbl_from_bseg USING <lfs_ce> CHANGING gt_bseg_1.
            WHEN '2'.
              PERFORM f_delete_augbl_from_bseg USING <lfs_ce> CHANGING gt_bseg_2.
            WHEN '3'.
              PERFORM f_delete_augbl_from_bseg USING <lfs_ce> CHANGING gt_bseg_3.
            WHEN '4'.
              PERFORM f_delete_augbl_from_bseg USING <lfs_ce> CHANGING gt_bseg_4.
            WHEN '5'.
              PERFORM f_delete_augbl_from_bseg USING <lfs_ce> CHANGING gt_bseg_5.
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "f_delete_remaining_clear_doc


*&---------------------------------------------------------------------*
*&      Form  f_delete_augbl_from_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PWA_CE     text
*      -->PT_BSEG    text
*----------------------------------------------------------------------*
FORM f_delete_augbl_from_bseg USING    pwa_ce TYPE ty_cash_expense
                              CHANGING pt_bseg TYPE ty_bseg_tab.

  CLEAR wa_bseg.
  MODIFY pt_bseg FROM wa_bseg TRANSPORTING augbl WHERE bukrs = pwa_ce-bukrs
                                                   AND belnr = pwa_ce-belnr
                                                   AND gjahr = pwa_ce-gjahr
                                                   AND buzei = pwa_ce-buzei.

ENDFORM.                    "f_delete_augbl_from_bseg


*&---------------------------------------------------------------------*
*&      Form  f_calculate_pro_rate_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_calculate_pro_rate_amount.

  FIELD-SYMBOLS: <lfs_expense> TYPE ty_expense,
                 <lfs_cash>    TYPE ty_cash,
                 <lfs_ce>      TYPE ty_cash_expense.
  DATA: lv_bank_amt    TYPE wrbtr,
        lv_expense_amt TYPE wrbtr.

*  SORT gt_cash_expense.
*  DELETE ADJACENT DUPLICATES FROM gt_cash_expense COMPARING ALL FIELDS.

* Substract Bank Amount with Conversion Gain/Loss
*  LOOP AT gt_cash_expense INTO wa_cash_expense WHERE augbl IS INITIAL.
*
*    IF wa_cash_expense-bukrs = wa_cash_expense-bukrs_bank
*    AND wa_cash_expense-belnr = wa_cash_expense-belnr_bank
*    AND wa_cash_expense-gjahr = wa_cash_expense-gjahr_bank
*    AND wa_cash_expense-hkont IN r_gainloss.
*        IF wa_cash_expense-shkzg = 'H' AND wa_cash_expense-shkzg_bank EQ 'H' OR
*           wa_cash_expense-shkzg = 'S' AND wa_cash_expense-shkzg_bank EQ 'S'.
*          wa_cash_expense-dmbtr_bank = wa_cash_expense-dmbtr_bank + wa_cash_expense-dmbtr.
*        ELSEIF wa_cash_expense-shkzg EQ 'H'.
*          wa_cash_expense-dmbtr_bank = wa_cash_expense-dmbtr_bank - wa_cash_expense-dmbtr.
*        ELSEIF wa_cash_expense-shkzg EQ 'S'.
*          wa_cash_expense-dmbtr_bank = wa_cash_expense-dmbtr_bank + wa_cash_expense-dmbtr.
*        ENDIF.
*
*      MODIFY gt_cash_expense FROM wa_cash_expense
*                     TRANSPORTING dmbtr_bank
*                            WHERE bukrs_bank = wa_cash_expense-bukrs_bank
*                              AND belnr_bank = wa_cash_expense-belnr_bank
*                              AND gjahr_bank = wa_cash_expense-gjahr_bank.
*
*    ENDIF.
*
*  ENDLOOP.

* Accumulate Total Cash per Expense
  CLEAR gt_expense[].
  LOOP AT gt_cash_expense INTO wa_cash_expense WHERE augbl IS INITIAL.

    READ TABLE gt_expense ASSIGNING <lfs_expense> WITH KEY bukrs = wa_cash_expense-bukrs
                                                           belnr = wa_cash_expense-belnr
                                                           gjahr = wa_cash_expense-gjahr
                                                           buzei = wa_cash_expense-buzei
                                                  BINARY SEARCH.
    IF sy-subrc = 0.
      IF wa_cash_expense-shkzg_bank = 'S'.
        <lfs_expense>-total_cash = <lfs_expense>-total_cash + wa_cash_expense-dmbtr_bank.
      ELSE.
        <lfs_expense>-total_cash = <lfs_expense>-total_cash - wa_cash_expense-dmbtr_bank.
      ENDIF.
    ELSE.
      CLEAR wa_expense.
      wa_expense-bukrs = wa_cash_expense-bukrs.
      wa_expense-belnr = wa_cash_expense-belnr.
      wa_expense-gjahr = wa_cash_expense-gjahr.
      wa_expense-buzei = wa_cash_expense-buzei.
      wa_expense-dmbtr = wa_cash_expense-dmbtr.
      IF wa_cash_expense-shkzg_bank = 'S'.
        wa_expense-total_cash = wa_cash_expense-dmbtr_bank.
      ELSE.
        wa_expense-total_cash = - wa_cash_expense-dmbtr_bank.
      ENDIF.
      INSERT wa_expense INTO TABLE gt_expense.
    ENDIF.

  ENDLOOP.

* Pro-rate
  CLEAR gt_cash[].
  LOOP AT gt_cash_expense ASSIGNING <lfs_ce> WHERE augbl IS INITIAL.

    READ TABLE gt_expense ASSIGNING <lfs_expense> WITH KEY bukrs = <lfs_ce>-bukrs
                                                           belnr = <lfs_ce>-belnr
                                                           gjahr = <lfs_ce>-gjahr
                                                           buzei = <lfs_ce>-buzei
                                                  BINARY SEARCH.
    IF sy-subrc = 0.

**     For Expense in Cash Document
*      IF <lfs_ce>-bukrs = <lfs_ce>-bukrs_bank
*      AND <lfs_ce>-belnr = <lfs_ce>-belnr_bank
*      AND <lfs_ce>-gjahr = <lfs_ce>-gjahr_bank.
**      AND ( <lfs_ce>-hkont IN r_gainloss OR
**            <lfs_ce>-hkont IN r_gl_cash ).
**       <lfs_ce>-cf_amount = <lfs_ce>-dmbtr.
*      ENDIF.

*     Add negative sign for Credit
      IF <lfs_ce>-shkzg_bank = 'H'.
        <lfs_ce>-dmbtr_bank = - <lfs_ce>-dmbtr_bank.
      ENDIF.
      IF <lfs_ce>-shkzg = 'H'.
        <lfs_ce>-dmbtr = - <lfs_ce>-dmbtr.
      ENDIF.

*     Pro-rate Formula
      IF <lfs_expense>-total_cash = 0.
        <lfs_ce>-cf_amount = 0.
      ELSE.
        <lfs_ce>-cf_amount = ( <lfs_ce>-dmbtr_bank / <lfs_expense>-total_cash ) * <lfs_ce>-dmbtr.
      ENDIF.

*        IF wa_cash_expense-shkzg = 'H'.
*          <lfs_expense>-total_exp = <lfs_expense>-total_exp - <lfs_ce>-cf_amount.
*        ELSE.
*          <lfs_expense>-total_exp = <lfs_expense>-total_exp + <lfs_ce>-cf_amount.
*        ENDIF.

*     Populate Total Calculation per Cash Item
      READ TABLE gt_cash ASSIGNING <lfs_cash> WITH KEY bukrs = <lfs_ce>-bukrs_bank
                                                       belnr = <lfs_ce>-belnr_bank
                                                       gjahr = <lfs_ce>-gjahr_bank
                                                       buzei = <lfs_ce>-buzei_bank
                                              BINARY SEARCH.
      IF sy-subrc = 0.
**       For Expense in Cash Document
*        IF <lfs_ce>-bukrs = <lfs_ce>-bukrs_bank
*        AND <lfs_ce>-belnr = <lfs_ce>-belnr_bank
*        AND <lfs_ce>-gjahr = <lfs_ce>-gjahr_bank.
*          <lfs_cash>-total_exp = <lfs_cash>-total_exp - <lfs_ce>-cf_amount.
*        ELSE.
*          IF <lfs_ce>-shkzg = 'H'.
*            <lfs_cash>-total_exp = <lfs_cash>-total_exp - <lfs_ce>-cf_amount.
*          ELSE.
*            <lfs_cash>-total_exp = <lfs_cash>-total_exp + <lfs_ce>-cf_amount.
*          ENDIF.
*        ENDIF.
        <lfs_cash>-total_exp = <lfs_cash>-total_exp - <lfs_ce>-cf_amount.
      ELSE.
        CLEAR wa_cash.
        wa_cash-bukrs = <lfs_ce>-bukrs_bank.
        wa_cash-belnr = <lfs_ce>-belnr_bank.
        wa_cash-gjahr = <lfs_ce>-gjahr_bank.
        wa_cash-buzei = <lfs_ce>-buzei_bank.

*       For Expense in Cash Document
*        IF <lfs_ce>-bukrs = <lfs_ce>-bukrs_bank
*        AND <lfs_ce>-belnr = <lfs_ce>-belnr_bank
*        AND <lfs_ce>-gjahr = <lfs_ce>-gjahr_bank.
*          wa_cash-dmbtr = <lfs_ce>-dmbtr_bank.
*          wa_cash-total_exp = - <lfs_ce>-cf_amount.
*        ELSE.
*          IF <lfs_ce>-shkzg_bank = 'S'.
*            wa_cash-dmbtr = - <lfs_ce>-dmbtr_bank.
*          ELSE.
*            wa_cash-dmbtr = <lfs_ce>-dmbtr_bank.
*          ENDIF.
*          IF <lfs_ce>-shkzg = 'H'.
*            wa_cash-total_exp = - <lfs_ce>-cf_amount.
*          ELSE.
*            wa_cash-total_exp = <lfs_ce>-cf_amount.
*          ENDIF.
*        ENDIF.
        wa_cash-dmbtr = <lfs_ce>-dmbtr_bank.
        wa_cash-total_exp = - <lfs_ce>-cf_amount.

        INSERT wa_cash INTO TABLE gt_cash.
      ENDIF.

    ENDIF.

  ENDLOOP.

* SORT gt_cash_expense BY dmbtr DESCENDING.
  LOOP AT gt_cash INTO wa_cash.

*   Add rounding difference to any first biggest expense that is found
    IF wa_cash-dmbtr NE wa_cash-total_exp.

      READ TABLE gt_cash_expense ASSIGNING <lfs_ce> WITH KEY bukrs_bank = wa_cash-bukrs
                                                             belnr_bank = wa_cash-belnr
                                                             gjahr_bank = wa_cash-gjahr
                                                             buzei_bank = wa_cash-buzei
                                                             augbl      = ''.
      IF sy-subrc = 0.
        IF wa_cash-dmbtr > wa_cash-total_exp.
          <lfs_ce>-cf_amount = <lfs_ce>-cf_amount - ( wa_cash-dmbtr - wa_cash-total_exp ).
        ELSE.
          <lfs_ce>-cf_amount = <lfs_ce>-cf_amount + ( wa_cash-total_exp - wa_cash-dmbtr ).
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "f_calculate_pro_rate_amount


*&---------------------------------------------------------------------*
*&      Form  f_get_total_transactions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_total_transactions.

  CLEAR gt_glt0[].

  SELECT bukrs
         ryear
         racct
         rbusa
         rtcur
         drcrk
         rpmax
         hslvt
         hsl01
         hsl02
         hsl03
         hsl04
         hsl05
         hsl06
         hsl07
         hsl08
         hsl09
         hsl10
         hsl11
         hsl12
         hsl13
         hsl14
         hsl15
         hsl16
    FROM glt0
    INTO TABLE gt_glt0
   WHERE bukrs = p_bukrs
     AND ryear = p_gjahr
     AND racct IN r_gl_cash.

ENDFORM.                    "f_get_closing_balance


*&---------------------------------------------------------------------*
*&      Form  f_get_cash_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_cash_document.

  FIELD-SYMBOLS: <lfs_bseg> TYPE ty_bseg.

  DATA: lt_bseg_cash  TYPE STANDARD TABLE OF ty_bseg,
        lwa_bseg_cash TYPE ty_bseg,
        lv_index      TYPE sy-tabix,
        lv_augbl      TYPE augbl,
        lt_bkpf_rev   LIKE gt_bkpf,
        lt_bkpf_12    LIKE gt_bkpf.

* Get initial document header
  CLEAR gt_bkpf[].
  SELECT bkpf~bukrs
         bkpf~belnr
         bkpf~gjahr
         bkpf~blart
         bkpf~budat
         bkpf~monat
         bkpf~waers
         bkpf~stblg
         bkpf~awkey
         bkpf~xreversal
    FROM bkpf
    JOIN bsis
      ON bsis~bukrs = bkpf~bukrs
     AND bsis~gjahr = bkpf~gjahr
     AND bsis~belnr = bkpf~belnr
    INTO TABLE gt_bkpf
    WHERE bkpf~bukrs = p_bukrs
      AND bkpf~belnr IN so_belnr
      AND bkpf~gjahr = p_gjahr
      AND bkpf~monat = gv_monat
      AND bsis~hkont  IN r_gl_cash.

* Get document also from BSAS (just in case someone cleared the cash item)
  SELECT bkpf~bukrs
         bkpf~belnr
         bkpf~gjahr
         bkpf~blart
         bkpf~budat
         bkpf~monat
         bkpf~waers
         bkpf~stblg
         bkpf~awkey
         bkpf~xreversal
    FROM bkpf
    JOIN bsas
      ON bsas~bukrs = bkpf~bukrs
     AND bsas~gjahr = bkpf~gjahr
     AND bsas~belnr = bkpf~belnr
    APPENDING TABLE gt_bkpf
    WHERE bkpf~bukrs = p_bukrs
      AND bkpf~belnr IN so_belnr
      AND bkpf~gjahr = p_gjahr
      AND bkpf~monat = gv_monat
      AND bsas~hkont IN r_gl_cash.

  CHECK gt_bkpf[] IS NOT INITIAL.


* Delete row(s) gt_bkpf if their reversal document EQ gv_monat


  "Prepare stblg for bkpf with xreversal 1 and 2
  REFRESH lt_bkpf_12.
  lt_bkpf_12[] = gt_bkpf[].
  DELETE lt_bkpf_12 WHERE xreversal EQ space.

  IF lt_bkpf_12[] IS NOT INITIAL.

    "Get all reversed & reversal document in BKPF based on stblg from lt_bkpf_12
    SELECT *
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_rev
       FOR ALL ENTRIES IN lt_bkpf_12
     WHERE bukrs  EQ lt_bkpf_12-bukrs
       AND belnr  EQ lt_bkpf_12-stblg
       AND gjahr  EQ lt_bkpf_12-gjahr.

    LOOP AT lt_bkpf_rev ASSIGNING <fs_bkpf> WHERE monat EQ gv_monat.

      "Delete row(s) gt_bkpf if their reversed or reversal document EQ gv_monat
      "Find gt_bkpf belnr by stblg from lt_bkpf_rev
      READ TABLE gt_bkpf TRANSPORTING NO FIELDS WITH KEY bukrs = <fs_bkpf>-bukrs
                                                         belnr = <fs_bkpf>-stblg
                                                         gjahr = <fs_bkpf>-gjahr.
      IF sy-subrc EQ 0.
        gv_tabix = sy-tabix.
        DELETE gt_bkpf INDEX gv_tabix.
      ENDIF.

    ENDLOOP.

  ENDIF.
  "}

* Get initial document items
  REFRESH gt_bseg_1[].
  SELECT bukrs
         belnr
         gjahr
         hkont
         buzei
         augbl
         augdt
         bschl
         shkzg
         dmbtr
         sgtxt
         zuonr
         umskz
         wrbtr
         vbund
         lifnr
         kunnr
         prctr
    FROM bseg
    INTO TABLE gt_bseg_1
    FOR ALL ENTRIES IN gt_bkpf
    WHERE bukrs EQ p_bukrs
    AND   gjahr EQ p_gjahr
    AND   belnr EQ gt_bkpf-belnr.

* Handling of specific case: Merge multiple cash item in the same document into one item
* This subroutine will modify GT_BSEG_1
  PERFORM f_combine_cash_item.

* Create Cash/Bank Items
  CLEAR lt_bseg_cash[].
  lt_bseg_cash[] = gt_bseg_1[].
  DELETE lt_bseg_cash WHERE hkont NOT IN r_gl_cash.
  SORT lt_bseg_cash BY bukrs belnr gjahr buzei.

* Handle Clearing between Cash Documents (Specific Feature)
  LOOP AT gt_bseg_1 ASSIGNING <lfs_bseg> WHERE hkont NOT IN r_gl_cash.
    IF <lfs_bseg>-belnr NE <lfs_bseg>-augbl
    AND <lfs_bseg>-augbl IS NOT INITIAL.
      CLEAR lwa_bseg_cash.
      READ TABLE lt_bseg_cash INTO lwa_bseg_cash WITH KEY bukrs = <lfs_bseg>-bukrs
                                                          belnr = <lfs_bseg>-augbl
                                               BINARY SEARCH.
      IF sy-subrc = 0.
        lv_augbl = <lfs_bseg>-augbl.
        CLEAR: <lfs_bseg>-augbl, <lfs_bseg>-augdt.
        MODIFY gt_bseg_1 FROM <lfs_bseg> TRANSPORTING augbl augdt WHERE belnr = <lfs_bseg>-belnr
                                                                    AND augbl = lv_augbl.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_bseg_1 ASSIGNING <lfs_bseg> WHERE hkont NOT IN r_gl_cash.

*   If the GL is an Expense GL, then delete the Clearing Doc (don't continue to next step)
    CLEAR wa_gl_map.
    READ TABLE gt_gl_map INTO wa_gl_map WITH KEY hkont = <lfs_bseg>-hkont
                                        BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR <lfs_bseg>-augbl.
      CLEAR <lfs_bseg>-augdt.
    ENDIF.

*   Delete Clearing Doc if Clearing Date > Clearing Date in Sel Screen
    IF p_augdt IS NOT INITIAL
    AND <lfs_bseg>-augdt IS NOT INITIAL
    AND <lfs_bseg>-augdt > p_augdt.
      CLEAR: <lfs_bseg>-augdt, <lfs_bseg>-augbl.
    ENDIF.

*   Create list of Cash-Expense
    CLEAR lwa_bseg_cash.
    READ TABLE lt_bseg_cash INTO lwa_bseg_cash WITH KEY bukrs = <lfs_bseg>-bukrs
                                                        belnr = <lfs_bseg>-belnr
                                                        gjahr = <lfs_bseg>-gjahr
                                               BINARY SEARCH.
    IF sy-subrc = 0.
      lv_index = sy-tabix.

      LOOP AT lt_bseg_cash INTO lwa_bseg_cash FROM lv_index.

*       WHERE condition
        IF lwa_bseg_cash-bukrs NE <lfs_bseg>-bukrs
        OR lwa_bseg_cash-belnr NE <lfs_bseg>-belnr
        OR lwa_bseg_cash-gjahr NE <lfs_bseg>-gjahr.
          EXIT.
        ENDIF.

*       Do not append to report if the item is the cash document
        IF lwa_bseg_cash-buzei = <lfs_bseg>-buzei.
          CONTINUE.
        ENDIF.

*       Do not append Expense with 0 Amount
        IF <lfs_bseg>-dmbtr IS NOT INITIAL.

          CLEAR wa_cash_expense.
          wa_cash_expense-bukrs_bank = lwa_bseg_cash-bukrs.
          wa_cash_expense-belnr_bank = lwa_bseg_cash-belnr.
          wa_cash_expense-gjahr_bank = lwa_bseg_cash-gjahr.
          wa_cash_expense-buzei_bank = lwa_bseg_cash-buzei.
          wa_cash_expense-shkzg_bank = lwa_bseg_cash-shkzg.
          wa_cash_expense-dmbtr_bank = lwa_bseg_cash-dmbtr.
          wa_cash_expense-bukrs      = <lfs_bseg>-bukrs.
          wa_cash_expense-belnr      = <lfs_bseg>-belnr.
          wa_cash_expense-gjahr      = <lfs_bseg>-gjahr.
          wa_cash_expense-buzei      = <lfs_bseg>-buzei.
          wa_cash_expense-shkzg      = <lfs_bseg>-shkzg.
          wa_cash_expense-dmbtr      = <lfs_bseg>-dmbtr.
          wa_cash_expense-augbl      = <lfs_bseg>-augbl.
          wa_cash_expense-hkont      = <lfs_bseg>-hkont.
          IF <lfs_bseg>-kunnr IS NOT INITIAL.
            wa_cash_expense-kunnr = <lfs_bseg>-kunnr.
          ENDIF.
          IF <lfs_bseg>-lifnr IS NOT INITIAL.
            wa_cash_expense-lifnr = <lfs_bseg>-lifnr.
          ENDIF.
          wa_cash_expense-step       = '1'.
          INSERT wa_cash_expense INTO TABLE gt_cash_expense.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT gt_bseg_1 BY bukrs belnr gjahr buzei.

ENDFORM.                    "f_get_cash_document


*&---------------------------------------------------------------------*
*&      Form  f_combine_cash_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_combine_cash_item.

  DATA: lt_bseg   TYPE STANDARD TABLE OF ty_bseg,
        lwa_bseg  TYPE ty_bseg,
        lv_index  TYPE sy-tabix,
        lv_amount TYPE wrbtr.

  SORT gt_bseg_1 BY bukrs belnr gjahr hkont.

  CLEAR lt_bseg[].

* For Cash Items, combine item with the same GL in the same document
  LOOP AT gt_bseg_1 INTO wa_bseg WHERE hkont IN r_gl_cash.

    AT NEW hkont.
      CLEAR lv_amount.
    ENDAT.

*   Transfer Working Area (supaya gak jadi bintang bintang)
    lwa_bseg = wa_bseg.

    IF lwa_bseg-shkzg = 'S'.
      lv_amount = lv_amount + lwa_bseg-dmbtr.
    ELSE.
      lv_amount = lv_amount - lwa_bseg-dmbtr.
    ENDIF.

    AT END OF hkont.
      lwa_bseg-dmbtr = abs( lv_amount ).
      IF lv_amount < 0.
        lwa_bseg-shkzg = 'H'.
      ELSE.
        lwa_bseg-shkzg = 'S'.
      ENDIF.
      APPEND lwa_bseg TO lt_bseg.
    ENDAT.

  ENDLOOP.

* For other items, then append regularly
  LOOP AT gt_bseg_1 INTO lwa_bseg WHERE hkont NOT IN r_gl_cash.
    APPEND lwa_bseg TO lt_bseg.
  ENDLOOP.

  gt_bseg_1[] = lt_bseg[].

ENDFORM.                    "f_combine_cash_item


*&---------------------------------------------------------------------*
*&      Form  f_get_next_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_BSEG_CURR  text
*      -->PT_BSEG_NEXT  text
*      -->PT_BSAS_NEXT  text
*----------------------------------------------------------------------*
FORM f_get_next_document USING    p_step       TYPE char1
                         CHANGING pt_bseg_curr TYPE ty_bseg_tab
                                  pt_bseg_next TYPE ty_bseg_tab
                                  pt_bsas_next TYPE ty_bsas_tab.

  TYPES: BEGIN OF ty_clearing_doc,
           augbl TYPE bsas-augbl,
           augdt TYPE bsas-augdt,
         END OF ty_clearing_doc.

  DATA: lt_bsas          TYPE STANDARD TABLE OF ty_bsas,
        lwa_bsas         TYPE ty_bsas,
        lt_tmp_bseg      TYPE STANDARD TABLE OF ty_bseg,
        lwa_bseg         TYPE ty_bseg,
        lv_index         TYPE sy-tabix,
        lv_index_next    TYPE sy-tabix,
        lv_index2        TYPE sy-tabix,
        lt_clearing_doc  TYPE STANDARD TABLE OF ty_clearing_doc,
        lwa_clearing_doc TYPE ty_clearing_doc,
        lv_is_cash       TYPE char1.

  FIELD-SYMBOLS: <lfs_bseg>         TYPE ty_bseg,
                 <lfs_curr>         TYPE ty_bseg,
                 <lfs_bsas>         TYPE ty_bsas,
                 <lfs_ce>           TYPE ty_cash_expense,
                 <lfs_clearing_doc> TYPE ty_clearing_doc.

  REFRESH: lt_tmp_bseg, lt_bsas.
  lt_tmp_bseg[] = pt_bseg_curr[].

* Delete items that don't have clearing doc
  DELETE lt_tmp_bseg WHERE augbl IS INITIAL.
*   OR augbl = 'X'.

* Sort and compress
  SORT lt_tmp_bseg BY hkont augdt augbl.
  DELETE ADJACENT DUPLICATES FROM lt_tmp_bseg COMPARING hkont augdt augbl.

  CHECK lt_tmp_bseg[] IS NOT INITIAL.

* Get clearing document info
  SELECT bukrs
         hkont
         augdt
         augbl
         zuonr
         gjahr
         belnr
        buzei
    FROM bsas
    INTO TABLE lt_bsas
    FOR ALL ENTRIES IN lt_tmp_bseg
    WHERE bukrs EQ p_bukrs
*    AND   hkont NOT IN r_hkont
    AND   augdt = lt_tmp_bseg-augdt
    AND   augbl = lt_tmp_bseg-augbl.

* Export BSAS
  pt_bsas_next[] = lt_bsas[].
  SORT pt_bsas_next BY augdt augbl.
  APPEND LINES OF pt_bsas_next[] TO gt_bsas[].
  SORT gt_bsas BY augdt augbl.

* Create Unique BSAS to Get BSEG
  SORT lt_bsas BY bukrs belnr gjahr buzei.
  DELETE ADJACENT DUPLICATES FROM lt_bsas COMPARING bukrs belnr gjahr buzei.

  CHECK lt_bsas[] IS NOT INITIAL.

* Get items of the clearing document
  SELECT bukrs
         belnr
         gjahr
         hkont
         buzei
         augbl
         augdt
         bschl
         shkzg
         dmbtr
         sgtxt
         zuonr
         umskz
         wrbtr
         vbund
         lifnr
         kunnr
         prctr
    FROM bseg
    INTO TABLE pt_bseg_next
    FOR ALL ENTRIES IN lt_bsas
    WHERE bukrs EQ lt_bsas-bukrs
    AND   gjahr EQ lt_bsas-gjahr
    AND   belnr EQ lt_bsas-belnr.
*    AND   hkont NOT IN gr_exclude_hkont.

  SORT pt_bseg_next BY bukrs belnr gjahr buzei.
  CLEAR lt_tmp_bseg[].
  lt_tmp_bseg[] =  pt_bseg_next[].
  SORT lt_tmp_bseg BY bukrs belnr gjahr buzei.

* Delete data from target BSEG that exists in source BSEG
*  LOOP AT pt_bseg_curr ASSIGNING <lfs_bseg>.
*    lv_index = sy-tabix.
*    READ TABLE pt_bseg_next TRANSPORTING NO FIELDS
*                            WITH KEY bukrs = <lfs_bseg>-bukrs
*                                     belnr = <lfs_bseg>-belnr
*                                     gjahr = <lfs_bseg>-gjahr
*                                     buzei = <lfs_bseg>-buzei
*                            BINARY SEARCH.
*    IF sy-subrc = 0.
*      DELETE pt_bseg_next INDEX lv_index.
*    ENDIF.
*  ENDLOOP.

  LOOP AT pt_bseg_next ASSIGNING <lfs_bseg>.

    lv_index_next = sy-tabix.

*   Delete Item in Previous Step
    READ TABLE pt_bseg_curr TRANSPORTING NO FIELDS
                            WITH KEY bukrs = <lfs_bseg>-bukrs
                                     belnr = <lfs_bseg>-belnr
                                     gjahr = <lfs_bseg>-gjahr
                                     buzei = <lfs_bseg>-buzei
                            BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE pt_bseg_next INDEX lv_index_next.
      CONTINUE.
    ENDIF.

*   Omit item that has the same Clearing Document as in this step
    READ TABLE gt_bsas INTO wa_bsas WITH KEY augdt = <lfs_bseg>-augdt
                                             augbl = <lfs_bseg>-augbl
                                    BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE pt_bseg_next INDEX lv_index_next.
      CONTINUE.
    ENDIF.

*   Delete Clearing Doc if Clearing Date > Clearing Date in Sel Screen
    IF p_augdt IS NOT INITIAL
    AND <lfs_bseg>-augdt IS NOT INITIAL
    AND <lfs_bseg>-augdt > p_augdt.
      CLEAR: <lfs_bseg>-augdt, <lfs_bseg>-augbl.
    ENDIF.

*   If the GL exists in GL mapping, treat like expense
    READ TABLE gt_gl_map INTO wa_gl_map WITH KEY hkont = <lfs_bseg>-hkont
                                        BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR: <lfs_bseg>-augbl, <lfs_bseg>-augdt.
    ENDIF.

*   If Item belongs to a Cash Document, mark it.
    CLEAR lv_is_cash.
    READ TABLE lt_tmp_bseg TRANSPORTING NO FIELDS WITH KEY bukrs = <lfs_bseg>-bukrs
                                                           belnr = <lfs_bseg>-belnr
                                                           gjahr = <lfs_bseg>-gjahr
                           BINARY SEARCH.
    IF sy-subrc = 0.
      lv_index2 = sy-tabix.
      LOOP AT lt_tmp_bseg INTO lwa_bseg FROM lv_index2.
        IF lwa_bseg-belnr NE <lfs_bseg>-belnr.
          EXIT.
        ENDIF.
        IF lwa_bseg-hkont IN r_gl_cash.
          lv_is_cash = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Create range of Clearing Documents
    CLEAR lt_clearing_doc[].
    READ TABLE lt_bsas TRANSPORTING NO FIELDS WITH KEY bukrs = <lfs_bseg>-bukrs
                                                       belnr = <lfs_bseg>-belnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      lv_index = sy-tabix.
      LOOP AT lt_bsas ASSIGNING <lfs_bsas> FROM lv_index.
        IF <lfs_bsas>-belnr NE <lfs_bseg>-belnr.
          EXIT.
        ENDIF.
        CLEAR lwa_clearing_doc.
        lwa_clearing_doc-augbl = <lfs_bsas>-augbl.
        lwa_clearing_doc-augdt = <lfs_bsas>-augdt.
        APPEND lwa_clearing_doc TO lt_clearing_doc.
      ENDLOOP.
    ENDIF.
    SORT lt_clearing_doc BY augdt augbl.

    LOOP AT lt_clearing_doc ASSIGNING <lfs_clearing_doc>.

      READ TABLE pt_bsas_next TRANSPORTING NO FIELDS WITH KEY augdt = <lfs_clearing_doc>-augdt
                                                              augbl = <lfs_clearing_doc>-augbl
                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        lv_index = sy-tabix.

*       Populate List of Cash-Expense Documents
        LOOP AT pt_bsas_next ASSIGNING <lfs_bsas> FROM lv_index.

*         Where condition
          IF <lfs_bsas>-augbl NE <lfs_clearing_doc>-augbl.
            EXIT.
          ENDIF.

*         This is to get Bank/Cash Document info
          READ TABLE gt_cash_expense ASSIGNING <lfs_ce> WITH KEY bukrs = <lfs_bsas>-bukrs
                                                                 belnr = <lfs_bsas>-belnr
                                                                 gjahr = <lfs_bsas>-gjahr
                                                                 buzei = <lfs_bsas>-buzei
                                                        BINARY SEARCH.
          IF sy-subrc = 0.

*           Get Previous Step Document Item
            READ TABLE pt_bseg_curr ASSIGNING <lfs_curr> WITH KEY bukrs = <lfs_bsas>-bukrs
                                                                  belnr = <lfs_bsas>-belnr
                                                                  gjahr = <lfs_bsas>-gjahr
                                                                  buzei = <lfs_bsas>-buzei
                                                         BINARY SEARCH.
            IF sy-subrc = 0.

*             If Expense is in another Cash Document, then delete Clearing Doc from Prev Doc
*             and do not continue.
              IF lv_is_cash = 'X'.
                DELETE pt_bseg_next INDEX lv_index_next.
*               Delete Clearing Document from Previous Step
                CLEAR: <lfs_curr>-augbl,
                       <lfs_ce>-augbl.
                CONTINUE.
              ENDIF.

*             Additional logic to prevent adding document that belongs to another Vendor
              IF <lfs_curr>-lifnr IS NOT INITIAL
              AND <lfs_bseg>-lifnr IS NOT INITIAL
              AND <lfs_curr>-lifnr NE <lfs_bseg>-lifnr.
                CONTINUE.
              ENDIF.

*             Additional logic to prevent adding document that belongs to another Customer
              IF <lfs_curr>-kunnr IS NOT INITIAL
              AND <lfs_bseg>-kunnr IS NOT INITIAL
              AND <lfs_curr>-kunnr NE <lfs_bseg>-kunnr.
                CONTINUE.
              ENDIF.

*             Do not append Expense with 0 Amount
              IF <lfs_bseg>-dmbtr IS NOT INITIAL.
                wa_cash_expense = <lfs_ce>.
                wa_cash_expense-bukrs = <lfs_bseg>-bukrs.
                wa_cash_expense-gjahr = <lfs_bseg>-gjahr.
                wa_cash_expense-belnr = <lfs_bseg>-belnr.
                wa_cash_expense-buzei = <lfs_bseg>-buzei.
                wa_cash_expense-shkzg = <lfs_bseg>-shkzg.
                wa_cash_expense-dmbtr = <lfs_bseg>-dmbtr.
                wa_cash_expense-augbl = <lfs_bseg>-augbl.
                wa_cash_expense-hkont = <lfs_bseg>-hkont.
                IF <lfs_bseg>-kunnr IS NOT INITIAL.
                  wa_cash_expense-kunnr = <lfs_bseg>-kunnr.
                ENDIF.
                IF <lfs_bseg>-lifnr IS NOT INITIAL.
                  wa_cash_expense-lifnr = <lfs_bseg>-lifnr.
                ENDIF.
                wa_cash_expense-step = p_step.
                INSERT wa_cash_expense INTO TABLE gt_cash_expense.
              ENDIF.

            ENDIF.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    "f_get_next_document



*&---------------------------------------------------------------------*
*&      Form  f_get_all_doc_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_all_doc_header.
  DATA : ls_bkpf    LIKE LINE OF gt_bkpf.

** Gather all item in one internal table
*  REFRESH gt_bseg[].
*  APPEND LINES OF gt_bseg_1 TO gt_bseg.
*  APPEND LINES OF gt_bseg_2 TO gt_bseg.
*  APPEND LINES OF gt_bseg_3 TO gt_bseg.
*  APPEND LINES OF gt_bseg_4 TO gt_bseg.
*  APPEND LINES OF gt_bseg_5 TO gt_bseg.
  SORT gt_bseg BY bukrs belnr gjahr buzei.
  DELETE ADJACENT DUPLICATES FROM gt_bseg COMPARING bukrs belnr gjahr buzei.

  CLEAR gt_bkpf[].
  CHECK gt_bseg[] IS NOT INITIAL.

* Get header information for all documents
  SELECT bukrs
         belnr
         gjahr
         blart
         budat
         monat
         waers
         awkey
    FROM bkpf AS bkpf
    APPENDING TABLE gt_bkpf
    FOR ALL ENTRIES IN gt_bseg
    WHERE bukrs EQ gt_bseg-bukrs
    AND   gjahr EQ gt_bseg-gjahr
    AND   belnr EQ gt_bseg-belnr.

* Get GL Account Description
  CLEAR gt_skat[].
  SELECT *
    FROM skat
    INTO TABLE gt_skat
     FOR ALL ENTRIES IN gt_bseg
   WHERE spras = sy-langu
     AND saknr = gt_bseg-hkont.
  SORT gt_skat BY saknr.

ENDFORM.                    "f_get_all_doc_header


*&---------------------------------------------------------------------*
*&      Form  f_populate_beginning_balance
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_beginning_balance.

  DATA: lv_hsl(13)  TYPE c,
        lv_cf(14)   TYPE c,
        lv_index(2) TYPE n,
        lv_balance  TYPE glt0-hsl01.

  FIELD-SYMBOLS: <lfs_hsl> TYPE glt0-hsl01,
                 <lfs_cf>  TYPE glt0-hsl01.

  CLEAR: wa_report, wa_cf_item.
  READ TABLE gt_cf_item INTO wa_cf_item WITH KEY strow = gc_beginning.
  MOVE-CORRESPONDING wa_cf_item TO wa_report.

*  wa_report-strow    = gc_beginning.
*  wa_report-text     = gc_beginning_t.
  wa_report-currency = gv_local_curr.

* Populate Beginning Balance for Jan (from Balance Carryforward)
  CLEAR lv_balance.
  LOOP AT gt_glt0 INTO wa_glt0.
    lv_balance = lv_balance + wa_glt0-hslvt.
  ENDLOOP.
  wa_report-cf01 = lv_balance.

* Populate Beginning Balance for the Rest of the Month
  lv_index = '01'.
  DO 11 TIMES.

*   Calculate Total Movement for That Month and accumulate to Balance
    LOOP AT gt_glt0 INTO wa_glt0.
      CONCATENATE 'WA_GLT0-HSL'
                  lv_index
             INTO lv_hsl.
      ASSIGN (lv_hsl) TO <lfs_hsl>.
      IF sy-subrc = 0.
        lv_balance = lv_balance + <lfs_hsl>.
      ENDIF.
    ENDLOOP.

*   Put into Report
    ADD 1 TO lv_index.
    CONCATENATE 'WA_REPORT-CF'
                lv_index
           INTO lv_cf.
    ASSIGN (lv_cf) TO <lfs_cf>.
    IF sy-subrc = 0.
      <lfs_cf> = lv_balance.
    ENDIF.

  ENDDO.

  APPEND wa_report TO gt_report.

ENDFORM.                    "f_populate_beginning_balance


*&---------------------------------------------------------------------*
*&      Form  f_populate_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_report.

  DATA: l_tabix     TYPE sy-tabix,
        lv_index(2) TYPE n,
        lv_cf(4)    TYPE c.

  FIELD-SYMBOLS: <lfs_parent> TYPE ty_cf_item,
                 <lfs_report> TYPE zdgstfi_cash_flow_header,
                 <lfs_cf>     TYPE hslxx.

  SORT gt_bkpf BY bukrs belnr gjahr.
  SORT gt_bseg_1 BY bukrs belnr gjahr.
  SORT gt_bseg_2 BY bukrs belnr gjahr.
  SORT gt_bseg_3 BY bukrs belnr gjahr.
  SORT gt_bseg_4 BY bukrs belnr gjahr.
  SORT gt_bseg_5 BY bukrs belnr gjahr.

  SORT gt_bseg_x BY bukrs belnr gjahr.
  SORT gt_bkpf_x BY bukrs belnr gjahr.

* Accunmulate Expense Amounts to Cash Flow Item
* Simply find document item with GL Account maintained in GL Mapping
* and accumulate the Cash Flow Item
  PERFORM f_accumulate_amount_to_item USING gt_bseg_1
                                            '1'.
  PERFORM f_accumulate_amount_to_item USING gt_bseg_2
                                            '2'.
  PERFORM f_accumulate_amount_to_item USING gt_bseg_3
                                            '3'.
  PERFORM f_accumulate_amount_to_item USING gt_bseg_4
                                            '4'.
  PERFORM f_accumulate_amount_to_item USING gt_bseg_5
                                            '5'.

  PERFORM f_accumulate_adjustment USING gt_bseg_x gt_bkpf_x.

* Populate Movements based on Previous Calculation
*  PERFORM f_populate_movement.

ENDFORM.                    "f_populate_report


*&---------------------------------------------------------------------*
*&      Form  f_populate_cash_flow_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_cash_flow_item.

  FIELD-SYMBOLS: <lfs_report> TYPE zdgstfi_cash_flow_header.

* Populate all Cash Flow Item
  LOOP AT gt_cf_item INTO wa_cf_item WHERE parent IS INITIAL.

*   This is a recursive function
    PERFORM f_populate_child_nodes CHANGING wa_cf_item.

  ENDLOOP.

ENDFORM.                    "f_manage_indentation


*&---------------------------------------------------------------------*
*&      Form  f_add_beginning_to_ending
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_add_beginning_to_ending.

  FIELD-SYMBOLS: <lfs_report> TYPE zdgstfi_cash_flow_header.

  SORT gt_report BY strow.

* Read Beginning Balance
  CLEAR wa_report.
  READ TABLE gt_report INTO wa_report WITH KEY strow = gc_beginning
                                      BINARY SEARCH.
  IF sy-subrc = 0.
*   Add Beginning Balance to Ending Balance
    READ TABLE gt_report ASSIGNING <lfs_report> WITH KEY strow = gc_ending
                                                BINARY SEARCH.
    IF sy-subrc = 0.
      <lfs_report>-cf01 = <lfs_report>-cf01 + wa_report-cf01.
      <lfs_report>-cf02 = <lfs_report>-cf02 + wa_report-cf02.
      <lfs_report>-cf03 = <lfs_report>-cf03 + wa_report-cf03.
      <lfs_report>-cf04 = <lfs_report>-cf04 + wa_report-cf04.
      <lfs_report>-cf05 = <lfs_report>-cf05 + wa_report-cf05.
      <lfs_report>-cf06 = <lfs_report>-cf06 + wa_report-cf06.
      <lfs_report>-cf07 = <lfs_report>-cf07 + wa_report-cf07.
      <lfs_report>-cf08 = <lfs_report>-cf08 + wa_report-cf08.
      <lfs_report>-cf09 = <lfs_report>-cf09 + wa_report-cf09.
      <lfs_report>-cf10 = <lfs_report>-cf10 + wa_report-cf10.
      <lfs_report>-cf11 = <lfs_report>-cf11 + wa_report-cf11.
      <lfs_report>-cf12 = <lfs_report>-cf12 + wa_report-cf12.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_add_beginning_to_ending


*&---------------------------------------------------------------------*
*&      Form  f_populate_child_nodes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CF_ITEM  text
*----------------------------------------------------------------------*
FORM f_populate_child_nodes CHANGING p_cf_item TYPE ty_cf_item.

  FIELD-SYMBOLS: <lfs_report> TYPE zdgstfi_cash_flow_header.

  DATA: lwa_cf_item TYPE ty_cf_item.

  LOOP AT gt_cf_item INTO lwa_cf_item WHERE parent = p_cf_item-strow.

*   Indent text for the next level
    PERFORM f_populate_child_nodes CHANGING lwa_cf_item.

    p_cf_item-cf01 = p_cf_item-cf01 + lwa_cf_item-cf01.
    p_cf_item-cf02 = p_cf_item-cf02 + lwa_cf_item-cf02.
    p_cf_item-cf03 = p_cf_item-cf03 + lwa_cf_item-cf03.
    p_cf_item-cf04 = p_cf_item-cf04 + lwa_cf_item-cf04.
    p_cf_item-cf05 = p_cf_item-cf05 + lwa_cf_item-cf05.
    p_cf_item-cf06 = p_cf_item-cf06 + lwa_cf_item-cf06.
    p_cf_item-cf07 = p_cf_item-cf07 + lwa_cf_item-cf07.
    p_cf_item-cf08 = p_cf_item-cf08 + lwa_cf_item-cf08.
    p_cf_item-cf09 = p_cf_item-cf09 + lwa_cf_item-cf09.
    p_cf_item-cf10 = p_cf_item-cf10 + lwa_cf_item-cf10.
    p_cf_item-cf11 = p_cf_item-cf11 + lwa_cf_item-cf11.
    p_cf_item-cf12 = p_cf_item-cf12 + lwa_cf_item-cf12.

  ENDLOOP.

  READ TABLE gt_report ASSIGNING <lfs_report> WITH KEY strow = p_cf_item-strow.
  IF sy-subrc = 0.
    <lfs_report>-cf01 = <lfs_report>-cf01 + p_cf_item-cf01.
    <lfs_report>-cf02 = <lfs_report>-cf02 + p_cf_item-cf02.
    <lfs_report>-cf03 = <lfs_report>-cf03 + p_cf_item-cf03.
    <lfs_report>-cf04 = <lfs_report>-cf04 + p_cf_item-cf04.
    <lfs_report>-cf05 = <lfs_report>-cf05 + p_cf_item-cf05.
    <lfs_report>-cf06 = <lfs_report>-cf06 + p_cf_item-cf06.
    <lfs_report>-cf07 = <lfs_report>-cf07 + p_cf_item-cf07.
    <lfs_report>-cf08 = <lfs_report>-cf08 + p_cf_item-cf08.
    <lfs_report>-cf09 = <lfs_report>-cf09 + p_cf_item-cf09.
    <lfs_report>-cf10 = <lfs_report>-cf10 + p_cf_item-cf10.
    <lfs_report>-cf11 = <lfs_report>-cf11 + p_cf_item-cf11.
    <lfs_report>-cf12 = <lfs_report>-cf12 + p_cf_item-cf12.
  ELSE.
    CLEAR wa_report.
    MOVE-CORRESPONDING p_cf_item TO wa_report.
    wa_report-currency = gv_local_curr.
    APPEND wa_report TO gt_report.
  ENDIF.

ENDFORM.                    "f_populate_child_nodes


*&---------------------------------------------------------------------*
*&      Form  f_manage_indentation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_manage_indentation.

  DATA: lv_indent TYPE char18.

  LOOP AT gt_cf_item INTO wa_cf_item WHERE parent IS INITIAL.

*   This is a recursive function
    CLEAR lv_indent.
    PERFORM f_indent_text USING wa_cf_item-strow
                          CHANGING lv_indent.

  ENDLOOP.

ENDFORM.                    "f_manage_indentation


*&---------------------------------------------------------------------*
*&      Form  f_indent_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STROW    text
*----------------------------------------------------------------------*
FORM f_indent_text USING    p_strow  TYPE zde_strow
                            p_indent TYPE any.

  FIELD-SYMBOLS: <lfs_report> TYPE zdgstfi_cash_flow_header.

  DATA: lwa_cf_item    TYPE ty_cf_item,
        lv_next_indent TYPE char18.

  CLEAR: lv_next_indent.
  lv_next_indent = p_indent.
  READ TABLE gt_cf_item TRANSPORTING NO FIELDS WITH KEY parent = p_strow.
  IF sy-subrc = 0.
    CONCATENATE '>>>'
                p_indent
           INTO lv_next_indent.
  ENDIF.

  LOOP AT gt_cf_item INTO lwa_cf_item WHERE parent = p_strow.

*   Append 2 spaces in front of Text
    READ TABLE gt_report ASSIGNING <lfs_report> WITH KEY strow = lwa_cf_item-strow
                                                BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE lv_next_indent
                  <lfs_report>-text
             INTO <lfs_report>-text.
*      REPLACE ALL OCCURRENCES OF '>' IN <lfs_report>-text WITH space.
      TRANSLATE <lfs_report>-text USING '> '.
    ENDIF.

*   Indent text for the next level
    PERFORM f_indent_text USING lwa_cf_item-strow
                                lv_next_indent.

  ENDLOOP.

ENDFORM.                    "f_indent_text


*&---------------------------------------------------------------------*
*&      Form  f_accumulate_ytd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_accumulate_ytd.

  DATA: l_tabix     TYPE sy-tabix,
        lv_index(2) TYPE n,
        lv_cf(4)    TYPE c.

  FIELD-SYMBOLS: <lfs_parent> TYPE ty_cf_item,
                 <lfs_report> TYPE zdgstfi_cash_flow_header,
                 <lfs_cf>     TYPE hslxx.

  LOOP AT gt_report ASSIGNING <lfs_report>.
    IF <lfs_report>-strow = gc_beginning.
      <lfs_report>-ytd = <lfs_report>-cf01.
    ELSEIF <lfs_report>-strow = gc_ending.
      CONCATENATE 'CF'
                  p_monat
             INTO lv_cf.
      ASSIGN COMPONENT lv_cf OF STRUCTURE <lfs_report> TO <lfs_cf>.
      IF sy-subrc = 0.
        <lfs_report>-ytd = <lfs_cf>.
      ENDIF.
    ELSE.
      lv_index = '01'.
      WHILE lv_index <= p_monat.
        CONCATENATE 'CF'
                    lv_index
               INTO lv_cf.
        ASSIGN COMPONENT lv_cf OF STRUCTURE <lfs_report> TO <lfs_cf>.
        IF sy-subrc = 0.
          <lfs_report>-ytd = <lfs_report>-ytd + <lfs_cf>.
        ENDIF.
        ADD 1 TO lv_index.
      ENDWHILE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_accumulate_ytd


*&---------------------------------------------------------------------*
*&      Form  f_populate_movement
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM f_populate_movement.
*
*  DATA: lv_index(2) TYPE n,
*        lv_cf(15)   TYPE c.
*
*  FIELD-SYMBOLS: <lfs_cf> TYPE dmbtr.
*
*  SORT gt_cf_item[] BY strow.
*  LOOP AT gt_cf_item INTO wa_cf_item.
*    CLEAR wa_report.
*    MOVE-CORRESPONDING wa_cf_item TO wa_report.
*    wa_report-currency = gv_local_curr.
*    APPEND wa_report TO gt_report.
*  ENDLOOP.
*
*ENDFORM.                    "f_populate_movement


*&---------------------------------------------------------------------*
*&      Form  f_accumulate_amount_to_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_BSEG    text
*----------------------------------------------------------------------*
FORM f_accumulate_amount_to_item USING pt_bseg TYPE ty_bseg_tab
                                       p_step  TYPE char1.

  FIELD-SYMBOLS: <lfs_cf_item> TYPE ty_cf_item,
                 <lfs_field>   TYPE dmbtr.
  DATA: lwa_bseg   TYPE ty_bseg,
        lwa_bseg_1 TYPE ty_bseg,
        lv_cf(4)   TYPE c.

* Loop at current step (only for Non Cash Items)
  LOOP AT pt_bseg INTO lwa_bseg WHERE augbl IS INITIAL.
*      AND hkont NOT IN r_gl_cash.

*   If First Document, Skip if GL is Cash GL
    IF p_step = '1' AND lwa_bseg-hkont IN r_gl_cash.
      CONTINUE.
    ENDIF.

*   Read GL Mapping. If found, then append to report
    CLEAR wa_gl_map.
    READ TABLE gt_gl_map INTO wa_gl_map WITH KEY hkont = lwa_bseg-hkont
                                                 shkzg = lwa_bseg-shkzg
                                        BINARY SEARCH.
    IF sy-subrc NE 0.
      READ TABLE gt_gl_map INTO wa_gl_map WITH KEY hkont = lwa_bseg-hkont
                                          BINARY SEARCH.
      IF sy-subrc NE 0.
        wa_gl_map-strow = gc_unmapped.
      ENDIF.
    ENDIF.

*   Accumulate amount to corresponding Cash Flow Item
    READ TABLE gt_cf_item ASSIGNING <lfs_cf_item>
                           WITH KEY strow = wa_gl_map-strow.
    IF sy-subrc = 0.

      LOOP AT gt_cash_expense INTO wa_cash_expense WHERE bukrs = lwa_bseg-bukrs
                                                     AND belnr = lwa_bseg-belnr
                                                     AND gjahr = lwa_bseg-gjahr
                                                     AND buzei = lwa_bseg-buzei.

*       Put amount to the right column (Jan or Feb or Mar, etc)
        CLEAR wa_bkpf.
        READ TABLE gt_bkpf INTO wa_bkpf WITH KEY bukrs = wa_cash_expense-bukrs_bank
                                                 belnr = wa_cash_expense-belnr_bank
                                                 gjahr = wa_cash_expense-gjahr_bank
                                        BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR lv_cf.
          CONCATENATE 'CF'
                      wa_bkpf-monat
                 INTO lv_cf.
          ASSIGN COMPONENT lv_cf OF STRUCTURE <lfs_cf_item> TO <lfs_field>.
          IF sy-subrc = 0.
*            IF lwa_bseg-shkzg = 'S'.
            <lfs_field> = <lfs_field> - wa_cash_expense-cf_amount.
*            ELSE.
*              <lfs_field> = <lfs_field> + wa_cash_expense-cf_amount.
*            ENDIF.
          ENDIF.
        ENDIF.

*       Put document bank main and document expense to Detail Report
        PERFORM f_populate_detail_report USING wa_gl_map-strow
                                               <lfs_cf_item>-text
                                               wa_cash_expense.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.                    "f_accumulate_amount_to_item


*&---------------------------------------------------------------------*
*&      Form  f_populate_detail_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STROW    text
*      -->P_TEXT     text
*      -->PWA_BSEG   text
*----------------------------------------------------------------------*
FORM f_populate_detail_report USING p_strow  TYPE zde_strow
                                    p_text   TYPE j_3rff4text
                                    pwa_ce   TYPE ty_cash_expense.

  DATA: lwa_bseg_cash    TYPE ty_bseg,
        lwa_bkpf_cash    TYPE ty_bkpf,
        lwa_bseg_expense TYPE ty_bseg,
        lwa_bkpf_expense TYPE ty_bkpf.

* Get Cash Document Header
  CLEAR lwa_bkpf_cash.
  READ TABLE gt_bkpf INTO lwa_bkpf_cash WITH KEY bukrs = pwa_ce-bukrs_bank
                                                 belnr = pwa_ce-belnr_bank
                                                 gjahr = pwa_ce-gjahr_bank
                                        BINARY SEARCH.

* Get Cash Document Item
  CLEAR lwa_bseg_cash.
  READ TABLE gt_bseg INTO lwa_bseg_cash WITH KEY bukrs = pwa_ce-bukrs_bank
                                                 belnr = pwa_ce-belnr_bank
                                                 gjahr = pwa_ce-gjahr_bank
                                                 buzei = pwa_ce-buzei_bank
                                        BINARY SEARCH.

  CLEAR wa_detail.
  wa_detail-strow  = p_strow.
  wa_detail-text   = p_text.
  wa_detail-monat  = lwa_bkpf_cash-monat.
  wa_detail-bukrs  = p_bukrs.
  wa_detail-belnr  = lwa_bseg_cash-belnr.
  wa_detail-gjahr  = lwa_bseg_cash-gjahr.
  wa_detail-buzei  = lwa_bseg_cash-buzei.
  wa_detail-budat  = lwa_bkpf_cash-budat.
  wa_detail-hkont  = lwa_bseg_cash-hkont.
  wa_detail-waers  = gv_local_curr.

* Get Cash/Bank GL Description
  CLEAR wa_skat.
  READ TABLE gt_skat INTO wa_skat WITH KEY saknr = lwa_bseg_cash-hkont
                                  BINARY SEARCH.
  IF sy-subrc = 0.
    wa_detail-txt20 = wa_skat-txt20.
  ENDIF.

* Populate Cash/Bank Amount in Local Currency
  IF lwa_bseg_cash-shkzg = 'H'.
*    wa_detail-wrbtr = - lwa_bseg_cash-wrbtr.
    wa_detail-dmbtr = - lwa_bseg_cash-dmbtr.
  ELSE.
*    wa_detail-wrbtr = lwa_bseg_cash-wrbtr.
    wa_detail-dmbtr = lwa_bseg_cash-dmbtr.
  ENDIF.

* Get Expense Document Header
  CLEAR lwa_bkpf_expense.
  READ TABLE gt_bkpf INTO lwa_bkpf_expense WITH KEY bukrs = pwa_ce-bukrs
                                                    belnr = pwa_ce-belnr
                                                    gjahr = pwa_ce-gjahr
                                           BINARY SEARCH.

* Get Expense Document Item
  CLEAR lwa_bseg_expense.
  READ TABLE gt_bseg INTO lwa_bseg_expense WITH KEY bukrs = pwa_ce-bukrs
                                                    belnr = pwa_ce-belnr
                                                    gjahr = pwa_ce-gjahr
                                                    buzei = pwa_ce-buzei
                                           BINARY SEARCH.

* Populate Expense Data
  wa_detail-ibelnr = lwa_bseg_expense-belnr.
  wa_detail-igjahr = lwa_bseg_expense-gjahr.
  wa_detail-ibuzei = lwa_bseg_expense-buzei.
  wa_detail-ihkont = lwa_bseg_expense-hkont.
  wa_detail-lifnr  = lwa_bseg_expense-lifnr.
  wa_detail-ivbund = lwa_bseg_expense-vbund.

* One Time Vendor/Customer
  CLEAR wa_bsec.
  READ TABLE gt_bsec INTO wa_bsec WITH KEY bukrs = lwa_bseg_expense-bukrs
                                           belnr = lwa_bseg_expense-belnr
                                           gjahr = lwa_bseg_expense-gjahr
                                  BINARY SEARCH.
  IF sy-subrc = 0.
    wa_detail-name1 = wa_bsec-name1.

* Vendor
  ELSEIF pwa_ce-lifnr IS NOT INITIAL.

    wa_detail-lifnr = pwa_ce-lifnr.
    CLEAR wa_lfa1.
    READ TABLE gt_lfa1 INTO wa_lfa1 WITH KEY lifnr = pwa_ce-lifnr
                                    BINARY SEARCH.
    IF sy-subrc = 0.
      wa_detail-name1 = wa_lfa1-name1.
    ENDIF.

* Customer
  ELSEIF pwa_ce-kunnr IS NOT INITIAL.
    wa_detail-lifnr = pwa_ce-kunnr.
    CLEAR wa_kna1.
    READ TABLE gt_kna1 INTO wa_kna1 WITH KEY kunnr = pwa_ce-kunnr
                                    BINARY SEARCH.
    IF sy-subrc = 0.
      wa_detail-name1 = wa_kna1-name1.
    ENDIF.

  ENDIF.

  wa_detail-iwaers = lwa_bkpf_expense-waers.
*  wa_detail-local_curr = gv_local_curr.
  wa_detail-sgtxt  = lwa_bseg_expense-sgtxt.

* Get Expense GL Description
  CLEAR wa_skat.
  READ TABLE gt_skat INTO wa_skat WITH KEY saknr = lwa_bseg_expense-hkont
                                  BINARY SEARCH.
  IF sy-subrc = 0.
    wa_detail-itxt20 = wa_skat-txt20.
  ENDIF.

* Populate Expense Amount
  IF lwa_bseg_expense-shkzg = 'S'.
    wa_detail-iwrbtr  = - lwa_bseg_expense-wrbtr.
*    wa_detail-idmbtr  = - pwa_ce-cf_amount.
  ELSE.
    wa_detail-iwrbtr  = lwa_bseg_expense-wrbtr.
*    wa_detail-idmbtr  = pwa_ce-cf_amount.
  ENDIF.
  wa_detail-idmbtr  = - pwa_ce-cf_amount.

* Change the sign for AP Expense (has the same doc as bank)
*  IF pwa_bseg-belnr = lwa_bseg_cash-belnr
*  AND pwa_bseg-gjahr = lwa_bseg_cash-gjahr.
*    wa_detail-iwrbtr  = - wa_detail-iwrbtr.
*    wa_detail-idmbtr  = - wa_detail-idmbtr.
*  ENDIF.

  INSERT wa_detail INTO TABLE gt_detail.

ENDFORM.                    "f_populate_detail_report


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_display_alv .

  DATA: l_callback_pf_status_set TYPE slis_formname,
        l_callback_user_command  TYPE slis_formname,
        ls_events                TYPE slis_alv_event,
        lv_index(2)              TYPE n,
        lv_longtext              TYPE t247-ltx.

  FIELD-SYMBOLS: <lfs_fieldcat> TYPE slis_fieldcat_alv.

  l_callback_pf_status_set = 'SET_LIST_STATUS'.
  l_callback_user_command = 'USER_COMMAND_MAIN'.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZDGSTFI_CASH_FLOW_HEADER'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
  ENDIF.

* Populate Column Name
  LOOP AT gt_fieldcat ASSIGNING <lfs_fieldcat>.

    IF <lfs_fieldcat>-fieldname = 'STROW'.
      <lfs_fieldcat>-key = 'X'.
      <lfs_fieldcat>-seltext_l = 'Item Code'.
      <lfs_fieldcat>-seltext_m = 'Item Code'.
      <lfs_fieldcat>-seltext_s = 'Item Code'.
      <lfs_fieldcat>-reptext_ddic = 'Item Code'.
    ELSEIF <lfs_fieldcat>-fieldname = 'TEXT'.
      <lfs_fieldcat>-key = 'X'.
      <lfs_fieldcat>-seltext_l = 'Text'.
      <lfs_fieldcat>-seltext_m = 'Text'.
      <lfs_fieldcat>-seltext_s = 'Text'.
      <lfs_fieldcat>-reptext_ddic = 'Text'.
    ELSEIF <lfs_fieldcat>-fieldname = 'YTD'.
      <lfs_fieldcat>-seltext_l = 'Year To Date'.
      <lfs_fieldcat>-seltext_m = 'Year To Date'.
      <lfs_fieldcat>-seltext_s = 'Year To Date'.
      <lfs_fieldcat>-reptext_ddic = 'Year To Date'.
    ELSEIF <lfs_fieldcat>-fieldname+0(2) = 'CF'.
      lv_index = <lfs_fieldcat>-fieldname+2(2).
      IF lv_index <= p_monat.
        CALL FUNCTION 'ISP_GET_MONTH_NAME'
          EXPORTING
*           DATE         = '00000000'
            language     = sy-langu
            month_number = lv_index
          IMPORTING
*           LANGU_BACK   =
            longtext     = lv_longtext
*           SHORTTEXT    =
*       EXCEPTIONS
*           CALENDAR_ID  = 1
*           DATE_ERROR   = 2
*           NOT_FOUND    = 3
*           WRONG_INPUT  = 4
*           OTHERS       = 5
          .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        <lfs_fieldcat>-seltext_l = lv_longtext.
        <lfs_fieldcat>-seltext_m = lv_longtext.
        <lfs_fieldcat>-seltext_s = lv_longtext.
        <lfs_fieldcat>-reptext_ddic = lv_longtext.
      ELSE.
        <lfs_fieldcat>-no_out = 'X'.
      ENDIF.
    ENDIF.

  ENDLOOP.

  SORT gt_report BY strow ASCENDING.
  CLEAR gv_repid.
  gv_repid = sy-repid.

* Add event TOP OF PAGE
  REFRESH gt_events[].
  ls_events-name = 'TOP_OF_PAGE'.
  ls_events-form = 'F_TOP_OF_PAGE'.
  APPEND ls_events TO gt_events.

  CLEAR gv_layout.
  gv_layout-colwidth_optimize = 'X'.
  gv_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = gv_repid
*     i_callback_pf_status_set       = l_callback_pf_status_set
      i_callback_user_command = l_callback_user_command
      is_layout               = gv_layout
      it_fieldcat             = gt_fieldcat
      it_events               = gt_events
    TABLES
      t_outtab                = gt_report
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  user_command_main
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_UCOMM     text
*      -->IS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command_main USING iv_ucomm LIKE sy-ucomm
                             is_selfield TYPE slis_selfield. "#EC *

  DATA: lwa_report TYPE zdgstfi_cash_flow_header.

* Drill down to original docs when User double clicks on the hotspots
  READ TABLE gt_report INTO lwa_report INDEX is_selfield-tabindex.
  IF sy-subrc EQ 0.

    PERFORM f_display_docs USING lwa_report
                                 is_selfield-fieldname.
  ENDIF.

ENDFORM.                    "user_command_main


*&---------------------------------------------------------------------*
*&      Form  f_display_docs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_LINE    text
*----------------------------------------------------------------------*
FORM f_display_docs USING pwa_line    TYPE zdgstfi_cash_flow_header
                          p_fieldname TYPE slis_fieldname.

  "ALV TABLE.
  DATA: lv_layout   TYPE slis_layout_alv,
        lt_sorttab  TYPE slis_t_sortinfo_alv,
        lwa_sort    TYPE slis_sortinfo_alv,
        lt_fieldcat TYPE slis_t_fieldcat_alv,
        lt_heading  TYPE slis_t_listheader,
        lt_events   TYPE slis_t_event,
        lv_strow    TYPE zde_strow,
        lv_monat    TYPE monat.

  FIELD-SYMBOLS: <lfs_fieldcat> TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = gv_repid
      i_structure_name       = 'ZDGSTFI_CASH_FLOW_ITEM'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Populate Column Name
  LOOP AT lt_fieldcat ASSIGNING <lfs_fieldcat>.

    CASE <lfs_fieldcat>-fieldname.
      WHEN 'BUDAT'.
        <lfs_fieldcat>-seltext_l = 'Pay Date'.
        <lfs_fieldcat>-seltext_m = 'Pay Date'.
        <lfs_fieldcat>-seltext_s = 'Pay Date'.
        <lfs_fieldcat>-reptext_ddic = 'Pay Date'.
      WHEN 'HKONT'.
        <lfs_fieldcat>-seltext_l = 'Bank/Cash'.
        <lfs_fieldcat>-seltext_m = 'Bank/Cash'.
        <lfs_fieldcat>-seltext_s = 'Bank/Cash'.
        <lfs_fieldcat>-reptext_ddic = 'Bank/Cash'.
      WHEN 'TXT20'.
        <lfs_fieldcat>-seltext_l = 'Bank/Cash Desc'.
        <lfs_fieldcat>-seltext_m = 'Bank/Cash Desc'.
        <lfs_fieldcat>-seltext_s = 'Bank/Cash Desc'.
        <lfs_fieldcat>-reptext_ddic = 'Bank/Cash Desc'.
      WHEN 'ITXT20'.
        <lfs_fieldcat>-seltext_l = 'G/L Acct Desc'.
        <lfs_fieldcat>-seltext_m = 'G/L Acct Desc'.
        <lfs_fieldcat>-seltext_s = 'G/L Acct Desc'.
        <lfs_fieldcat>-reptext_ddic = 'G/L Acct Desc'.
      WHEN 'DMBTR'.
        <lfs_fieldcat>-seltext_l = 'Bank Amt'.
        <lfs_fieldcat>-seltext_m = 'Bank Amt'.
        <lfs_fieldcat>-seltext_s = 'Bank Amt'.
        <lfs_fieldcat>-reptext_ddic = 'Bank Amt'.
      WHEN 'IVBUND'.
        <lfs_fieldcat>-seltext_l = 'Tr. Prt.'.
        <lfs_fieldcat>-seltext_m = 'Tr. Prt.'.
        <lfs_fieldcat>-seltext_s = 'Tr. Prt.'.
        <lfs_fieldcat>-reptext_ddic = 'Tr. Prt.'.
      WHEN 'IBELNR'.
        <lfs_fieldcat>-seltext_l = 'Invoice Doc. No.'.
        <lfs_fieldcat>-seltext_m = 'Invoice Doc. No.'.
        <lfs_fieldcat>-seltext_s = 'Invoice Doc. No.'.
        <lfs_fieldcat>-reptext_ddic = 'Invoice Doc. No.'.
      WHEN 'LIFNR'.
        <lfs_fieldcat>-seltext_l = 'Customer/Vendor'.
        <lfs_fieldcat>-seltext_m = 'Cust/Vendor'.
        <lfs_fieldcat>-seltext_s = 'Cust/Vendor'.
        <lfs_fieldcat>-reptext_ddic = 'Customer/Vendor'.


      WHEN 'IDMBTR'.
        <lfs_fieldcat>-do_sum = 'X'.
      WHEN 'BUZEI'.
        <lfs_fieldcat>-no_out = 'X'.
      WHEN 'IBUZEI'.
        <lfs_fieldcat>-no_out = 'X'.
      WHEN 'MONAT'.
        <lfs_fieldcat>-no_out = 'X'.
      WHEN 'STROW'.
        <lfs_fieldcat>-no_out = 'X'.
      WHEN 'TEXT'.
        <lfs_fieldcat>-no_out = 'X'.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

* Get the selected document items
  CLEAR: gt_selected[], lv_strow, lv_monat.
  lv_strow = pwa_line-strow.
  IF p_fieldname NE 'YTD'.
    lv_monat = p_fieldname+2(2).
  ENDIF.
* This is a recursive function
  PERFORM f_select_doc_to_display USING lv_strow
                                        lv_monat.

  SORT gt_selected BY belnr gjahr buzei ibelnr igjahr ibuzei.
  DELETE ADJACENT DUPLICATES FROM gt_selected COMPARING belnr gjahr buzei ibelnr igjahr ibuzei.
  DELETE gt_selected WHERE belnr IS INITIAL.

  CLEAR gv_layout.
  gv_layout-colwidth_optimize = 'X'.

  CLEAR lt_sorttab[].
  CLEAR lwa_sort.
  lwa_sort-spos = '1'.
  lwa_sort-fieldname = 'BELNR'.
  lwa_sort-up        = 'X'.
  lwa_sort-subtot    = 'X'.
  APPEND lwa_sort TO lt_sorttab.

* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'F_SET_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gv_layout
      it_fieldcat              = lt_fieldcat
      it_sort                  = lt_sorttab
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_selected.

ENDFORM.                    "f_display_docs


*&---------------------------------------------------------------------*
*&      Form  f_select_doc_to_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STROW    text
*      -->P_MONAT    text
*----------------------------------------------------------------------*
FORM f_select_doc_to_display USING p_strow TYPE zde_strow
                                   p_monat TYPE monat.

* Loop first at the children
  LOOP AT gt_cf_item INTO wa_cf_item WHERE parent = p_strow.
*   Recursive call
    PERFORM f_select_doc_to_display USING wa_cf_item-strow
                                          p_monat.
  ENDLOOP.

* Append to report
  LOOP AT gt_detail INTO wa_detail WHERE strow = p_strow.
*   For YTD, append all. For Jan-Dec, append only for the corresponding month
    IF p_monat IS NOT INITIAL
    AND wa_detail-monat NE p_monat.
      CONTINUE.
    ENDIF.
    APPEND wa_detail TO gt_selected.
  ENDLOOP.

ENDFORM.                    "f_select_doc_to_display


*&---------------------------------------------------------------------*
*&      Form  f_set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM f_set_status USING extab TYPE slis_t_extab.            "#EC *

  SET PF-STATUS 'DETAIL' EXCLUDING extab.

ENDFORM.                    "se   t_list_status


*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm               "#EC CALLED
                        rs_selfield TYPE slis_selfield.

  DATA: lwa_detail TYPE zdgstfi_cash_flow_item.

  IF r_ucomm = gc_double_click.
    READ TABLE gt_selected INTO lwa_detail INDEX rs_selfield-tabindex.
    IF sy-subrc EQ 0.
      SET PARAMETER ID 'BUK' FIELD lwa_detail-bukrs.
      SET PARAMETER ID 'BLN' FIELD lwa_detail-belnr.
      SET PARAMETER ID 'GJR' FIELD lwa_detail-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDIF.
  ELSEIF r_ucomm = gc_show_invoice.
** Display invoice
    READ TABLE gt_selected INTO lwa_detail INDEX rs_selfield-tabindex.
    IF sy-subrc EQ 0.
      SET PARAMETER ID 'BUK' FIELD lwa_detail-bukrs.
      SET PARAMETER ID 'BLN' FIELD lwa_detail-ibelnr.
      SET PARAMETER ID 'GJR' FIELD lwa_detail-igjahr.
      IF lwa_detail-ibelnr IS INITIAL.
        MESSAGE e611(9p).
      ELSE.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "user_command


*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: lv_text(50)     TYPE c,
        lv_company_name TYPE butxt.

* Get Company Name
  CLEAR lv_company_name.
  SELECT SINGLE butxt
           FROM t001
           INTO lv_company_name
          WHERE bukrs = p_bukrs.

  FORMAT COLOR COL_HEADING.
  WRITE:/1(200) 'CASH FLOW REPORT' CENTERED.
  WRITE:/1(200) gs_stmt-vstxt CENTERED.
*  WRITE:/1(200) lv_company_name CENTERED.

  CONCATENATE '01/'
              p_gjahr
              '-'
              p_monat
              '/'
              p_gjahr
         INTO lv_text.
  WRITE:/1(200) lv_text CENTERED.

**  FORMAT COLOR COL_NORMAL.
*  WRITE:/1(152) 'Company Code      :', p_bukrs.
**  FORMAT COLOR COL_HEADING.
*  WRITE:/1(152) 'Period            :', '01', '-', p_monat CENTERED.
**  FORMAT COLOR COL_NORMAL.
*  WRITE:/1(152) 'Fiscal Year       :', p_gjahr CENTERED.
**  FORMAT COLOR COL_HEADING.
*  WRITE:/1(152) 'As of             :', sy-datum, '-', sy-uzeit CENTERED.

ENDFORM.                    "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_PROGRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1096   text
*----------------------------------------------------------------------*
FORM f_progres  USING VALUE(u_text).

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = u_text.

ENDFORM.                    " F_PROGRES

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PGS' '' '' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'PVE' '' '' '0' '' '' '',
                                      'SBE' '' '' '0' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group1 fu_group2 fu_name fu_active fu_input
                               fu_invisible fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_pf_status.
  PERFORM f_pbo.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PF_STATUS
*&---------------------------------------------------------------------*
FORM f_pf_status .
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITLE01'.

  DESCRIBE TABLE gt_007 LINES fill.
  tc_007-lines = fill.
ENDFORM.                    " F_PF_STATUS

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  gs_007-bukrs    = p_bukrs.
  gs_007-gsber    = p_gsber.
  gs_007-monat    = p_monat.
  gs_007-gjahr    = p_gjahr.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  PERFORM f_fill_table_control.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  PERFORM f_read_table_control.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  DATA : ls_skb1    LIKE LINE OF gt_skb1.

  READ TABLE gt_007 INTO gs_007 INDEX tc_007-current_line.

  IF gs_007-hkont IS NOT INITIAL.
    CLEAR ls_skb1.
    READ TABLE gt_skb1 INTO ls_skb1
                       WITH KEY bukrs = p_bukrs
                                saknr = gs_007-hkont.
    IF sy-subrc <> 0.
      MESSAGE s030(msitem) DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FILL_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  MODIFY gt_007 FROM gs_007
                INDEX tc_007-current_line
                TRANSPORTING belnr hkont waers dmbtr mark.
  IF sy-subrc <> 0.
    APPEND gs_007 TO gt_007.
  ENDIF.
ENDFORM.                    " F_READ_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lt_007  TYPE STANDARD TABLE OF zdgfidt007,
         lt_007d TYPE STANDARD TABLE OF zdgfidt007,
         ls_007  LIKE LINE OF gt_007.

  DATA : lv_ucomm TYPE sy-ucomm,
         lv_line1 TYPE i,
         lv_line2 TYPE i.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN 'SALL'.
      LOOP AT gt_007 INTO ls_007.
        ls_007-mark  = 'X'.
        MODIFY gt_007 FROM ls_007 TRANSPORTING mark.
      ENDLOOP.

    WHEN 'DSAL'.
      LOOP AT gt_007 INTO ls_007.
        CLEAR ls_007-mark.
        MODIFY gt_007 FROM ls_007 TRANSPORTING mark.
      ENDLOOP.

    WHEN 'ADDI'.
      CALL SELECTION-SCREEN 900 STARTING AT 10 10.
      IF so_beln1[] IS NOT INITIAL.
        PERFORM f_get_adjustment_document USING 'Y'.
      ENDIF.

    WHEN 'FILT'.
      CALL SELECTION-SCREEN 900 STARTING AT 10 10.
      IF so_beln1[] IS NOT INITIAL.
        PERFORM f_filter_document.
      ENDIF.

    WHEN 'DELE'.
      LOOP AT gt_007 INTO ls_007 WHERE mark IS NOT INITIAL.
        ls_007-statu  = icon_delete.
        MODIFY gt_007 FROM ls_007 TRANSPORTING statu.
        APPEND ls_007 TO lt_007d.
      ENDLOOP.

    WHEN 'UNDE'.
      LOOP AT gt_007 INTO ls_007 WHERE mark IS NOT INITIAL.
        DELETE lt_007d WHERE belnr = ls_007-belnr
                         AND hkont = ls_007-hkont.
        CLEAR ls_007-statu.
        MODIFY gt_007 FROM ls_007 TRANSPORTING statu.
      ENDLOOP.

    WHEN 'SAVE'.
      lt_007[] = gt_007[].
      SORT lt_007 BY bukrs gsber monat gjahr belnr hkont.
      DELETE ADJACENT DUPLICATES FROM lt_007
      COMPARING bukrs gsber monat gjahr belnr hkont.

      DESCRIBE TABLE gt_007 LINES lv_line1.
      DESCRIBE TABLE lt_007 LINES lv_line2.
      IF lv_line1 = lv_line2.
        LOOP AT gt_007 INTO ls_007.
          IF ls_007-dmbtr < 0.
            ls_007-shkzg = 'H'.
            ls_007-dmbtr = abs( ls_007-dmbtr ).
          ELSE.
            ls_007-shkzg = 'S'.
          ENDIF.
          MODIFY gt_007 FROM ls_007.
        ENDLOOP.

        MODIFY zdgfidt007 FROM TABLE gt_007.
        IF lt_007d[] IS NOT INITIAL.
          DELETE zdgfidt007 FROM TABLE lt_007d.
        ENDIF.
        MESSAGE s000(zab) WITH 'Data already saved'.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE s000(zab) WITH 'Duplicated data' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  SELECT bukrs saknr
    FROM skb1
    INTO TABLE gt_skb1
    WHERE bukrs = p_bukrs.

  SELECT SINGLE butxt
    FROM t001
    INTO gv_butxt
    WHERE bukrs = p_bukrs.

  SELECT SINGLE gtext
    FROM tgsbt
    INTO gv_gtext
    WHERE spras = sy-langu
      AND gsber = p_gsber.

  PERFORM f_get_adjustment_document USING ''.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_ADJUSTMENT_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_adjustment_document USING      fu_proc.
  DATA : lt_x007 TYPE STANDARD TABLE OF zdgfidt007,
         ls_007  LIKE LINE OF gt_007,
         ls_x007 LIKE LINE OF lt_x007,
         ls_bseg LIKE LINE OF gt_bseg,
         ls_bkpf LIKE LINE OF gt_bkpf,
         ls_cash TYPE ty_cash_expense.

  DATA : lt_xbkpf TYPE STANDARD TABLE OF ty_xbkpf,
         lt_xbseg TYPE STANDARD TABLE OF ty_xbseg,
         lt_ybseg TYPE ty_xbseg OCCURS 1,
         ls_xbkpf LIKE LINE OF lt_xbkpf,
         ls_xbseg LIKE LINE OF lt_xbseg,
         ls_ybseg LIKE LINE OF lt_ybseg,
         lt_bkpf  TYPE STANDARD TABLE OF ty_xbkpf.

  DATA : lv_buzei       TYPE bseg-buzei,
         lv_tabix       TYPE sy-tabix,
         lv_objkey(20),
         lv_xobjkey(20).

  CLEAR : gt_bseg_x[], gt_bkpf_x[], gt_skat_x[].

  CASE fu_proc.
    WHEN 'X'.
      CLEAR : gt_007[].

      SELECT *
        FROM zdgfidt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE bukrs = p_bukrs
          AND monat = gv_monat
          AND gjahr = p_gjahr
          AND belnr IN so_belnr.

*****      PERFORM f_get_data_bsas TABLES lt_xbkpf
*****                                     lt_xbseg.

      SORT gt_007 BY bukrs belnr gjahr.
      SORT lt_xbkpf BY bukrs belnr gjahr.
      SORT lt_xbseg BY bukrs belnr gjahr.

      lt_x007[] = gt_007[].
      SORT lt_x007 BY bukrs belnr gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING bukrs belnr gjahr.
      IF lt_x007[] IS NOT INITIAL.
        LOOP AT lt_x007 INTO ls_x007.
          MOVE-CORRESPONDING ls_x007 TO ls_bkpf.
          CLEAR ls_xbkpf.
          READ TABLE lt_xbkpf INTO ls_xbkpf
                              WITH KEY bukrs = ls_x007-bukrs
                                       belnr = ls_x007-belnr
                                       gjahr = ls_x007-gjahr
                              BINARY SEARCH.
          IF sy-subrc = 0.
            ls_bkpf-waers = ls_xbkpf-waers.
          ENDIF.
          APPEND ls_bkpf TO gt_bkpf_x.

          CLEAR : ls_007, lv_tabix.
          READ TABLE gt_007 INTO ls_007
                              WITH KEY bukrs = ls_x007-bukrs
                                       belnr = ls_x007-belnr
                                       gjahr = ls_x007-gjahr
                              BINARY SEARCH.
          IF sy-subrc = 0.
            CONCATENATE ls_x007-bukrs ls_x007-belnr ls_x007-gjahr INTO lv_xobjkey.
            lv_tabix  = sy-tabix.

            CLEAR ls_007.
            LOOP AT gt_007 INTO ls_007 FROM lv_tabix.
              CONCATENATE ls_007-bukrs ls_007-belnr ls_007-gjahr INTO lv_objkey.
              IF lv_objkey <> lv_xobjkey.
                EXIT.
              ENDIF.
              IF ls_007-wrbtr = 0.
                ls_007-wrbtr = ls_007-dmbtr.
              ENDIF.
              MOVE-CORRESPONDING ls_007 TO ls_bseg.
              ADD 1 TO lv_buzei.
              ls_bseg-buzei = lv_buzei.
              APPEND ls_bseg TO gt_bseg_x.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDIF.

      lt_x007[] = gt_007[].
      SORT lt_x007 BY hkont.
      DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING hkont.
      IF lt_x007[] IS NOT INITIAL.
        CLEAR gt_skat_x[].
        SELECT *
          FROM skat
          INTO TABLE gt_skat_x
           FOR ALL ENTRIES IN lt_x007
         WHERE spras = sy-langu
           AND saknr = lt_x007-hkont.
        SORT gt_skat_x BY saknr.
      ENDIF.

    WHEN 'Y'.
      LOOP AT so_beln1.
        ls_bkpf-bukrs = p_bukrs.
        ls_bkpf-belnr = so_beln1-low.
        ls_bkpf-gjahr = pa_gjahr.
        ls_bkpf-monat = p_monat.
        APPEND ls_bkpf TO lt_bkpf.
      ENDLOOP.

      IF lt_bkpf[] IS NOT INITIAL.
        SELECT bukrs belnr gjahr monat waers
          FROM bkpf
          INTO TABLE lt_xbkpf
          FOR ALL ENTRIES IN lt_bkpf
          WHERE bukrs = p_bukrs
            AND belnr = lt_bkpf-belnr
            AND gjahr = pa_gjahr.
        IF lt_xbkpf[] IS NOT INITIAL.
          SELECT bukrs belnr gjahr buzei augdt shkzg gsber dmbtr wrbtr
            sgtxt hkont
            FROM bseg
            INTO TABLE lt_xbseg
            FOR ALL ENTRIES IN lt_xbkpf
            WHERE bukrs = p_bukrs
              AND belnr = lt_xbkpf-belnr
              AND gjahr = pa_gjahr.
        ENDIF.

        SORT lt_xbseg BY hkont.
        LOOP AT lt_xbseg INTO ls_xbseg.
          MOVE-CORRESPONDING ls_xbseg TO ls_007.
          IF ls_xbseg-shkzg = 'H'.
            ls_007-dmbtr  = ls_007-dmbtr * -1.
          ENDIF.
          CLEAR ls_xbkpf.
          READ TABLE lt_xbkpf INTO ls_xbkpf
                              WITH KEY bukrs = ls_xbseg-bukrs
                                       belnr = ls_xbseg-belnr
                                       gjahr = ls_xbseg-gjahr.
          IF sy-subrc = 0.
            ls_007-gjahr  = p_gjahr.
            ls_007-monat  = p_monat.
            ls_007-waers  = ls_xbkpf-waers.
          ENDIF.
          CLEAR ls_007-shkzg.
          COLLECT ls_007 INTO gt_007.
          CLEAR ls_007.
        ENDLOOP.

        LOOP AT gt_007 INTO ls_007.
          IF ls_007-dmbtr < 0.
            ls_007-shkzg = 'H'.
          ELSE.
            ls_007-shkzg = 'S'.
          ENDIF.
          MODIFY gt_007 FROM ls_007 TRANSPORTING shkzg.
        ENDLOOP.
      ENDIF.

      IF gt_007[] IS INITIAL.
        MESSAGE s000(zab) WITH 'Document not found' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN OTHERS.
      CLEAR gt_007[].
      SELECT *
        FROM zdgfidt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        WHERE bukrs = p_bukrs
          AND gsber = p_gsber
          AND monat = p_monat
          AND gjahr = p_gjahr.

      LOOP AT gt_007 INTO ls_007.
        IF ls_007-shkzg = 'H'.
          ls_007-dmbtr = ls_007-dmbtr * -1.
          MODIFY gt_007 FROM ls_007 TRANSPORTING wrbtr dmbtr.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_GET_ADJUSTMENT_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_ACCUMULATE_ADJUSTMENT
*&---------------------------------------------------------------------*
FORM f_accumulate_adjustment  USING    ft_bseg  TYPE ty_bseg_tab
                                       ft_bkpf  TYPE ty_bkpf_tab.
  DATA : ls_bseg TYPE ty_bseg,
         ls_bkpf TYPE ty_bkpf.

  DATA : lv_cf(4) TYPE c,
         lv_budat TYPE sy-datum.

  FIELD-SYMBOLS : <lfs_cf_item> TYPE ty_cf_item,
                  <lfs_field>   TYPE dmbtr.

  LOOP AT ft_bseg INTO ls_bseg.
    CLEAR wa_gl_map.
    READ TABLE gt_gl_map INTO wa_gl_map
                         WITH KEY hkont = ls_bseg-hkont.
    IF sy-subrc = 0.
      CLEAR ls_bkpf.
      READ TABLE ft_bkpf INTO ls_bkpf
                         WITH KEY bukrs = ls_bseg-bukrs
                                  belnr = ls_bseg-belnr
                                  gjahr = ls_bseg-gjahr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR wa_detail.
        wa_detail-strow  = wa_gl_map-strow.

        CLEAR wa_cf_item.
        READ TABLE gt_cf_item ASSIGNING <lfs_cf_item>
                              WITH KEY strow = wa_gl_map-strow.

        CLEAR lv_cf.
        CONCATENATE 'CF'
                    ls_bkpf-monat
               INTO lv_cf.
        ASSIGN COMPONENT lv_cf OF STRUCTURE <lfs_cf_item> TO <lfs_field>.
        IF sy-subrc = 0.
          CASE ls_bseg-shkzg.
            WHEN 'H'.
              <lfs_field> = <lfs_field> - ls_bseg-dmbtr.
            WHEN 'S'.
              <lfs_field> = <lfs_field> + ls_bseg-dmbtr.
          ENDCASE.
        ENDIF.

        CONCATENATE ls_bkpf-gjahr ls_bkpf-monat '01' INTO lv_budat.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_budat
          IMPORTING
            last_day_of_month = wa_detail-budat
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

        wa_detail-text    = <lfs_cf_item>-text.
        wa_detail-monat   = ls_bkpf-monat.
        wa_detail-bukrs   = p_bukrs.
        wa_detail-belnr   = ls_bseg-belnr.
        wa_detail-gjahr   = ls_bseg-gjahr.
        wa_detail-buzei   = ls_bseg-buzei.
        wa_detail-ihkont  = ls_bseg-hkont.
        wa_detail-waers   = gv_local_curr.
        wa_detail-sgtxt   = 'Adjustment Report'.
* Get Cash/Bank GL Description
        CLEAR wa_skat.
        READ TABLE gt_skat_x INTO wa_skat WITH KEY saknr = ls_bseg-hkont
                                          BINARY SEARCH.
        IF sy-subrc = 0.
          wa_detail-itxt20 = wa_skat-txt20.
        ENDIF.

* Populate Cash/Bank Amount in Local Currency
        wa_detail-iwaers  = ls_bkpf-waers.
        IF ls_bseg-shkzg = 'H'.
          wa_detail-idmbtr = - ls_bseg-dmbtr.
          wa_detail-iwrbtr = - ls_bseg-wrbtr.
        ELSE.
          wa_detail-idmbtr = ls_bseg-dmbtr.
          wa_detail-iwrbtr = ls_bseg-wrbtr.
        ENDIF.

        INSERT wa_detail INTO TABLE gt_detail.
        CLEAR wa_detail.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ACCUMULATE_ADJUSTMENT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  DATA : ls_t001    TYPE t001.

  CASE 'X'.
    WHEN radio2.
      IF p_bukrs IS NOT INITIAL.
        SELECT SINGLE *
          FROM t001
          INTO ls_t001
          WHERE bukrs = p_bukrs.
        IF sy-subrc <> 0.
          PERFORM f_error_message USING 'PBU' 'Company code is not defined'.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_filter_document .
  DATA : lt_x007 TYPE STANDARD TABLE OF ty_007,
         ls_x007 LIKE LINE OF lt_x007.

  lt_x007[] = gt_007[].
  CLEAR gt_007[].

  LOOP AT lt_x007 INTO ls_x007 WHERE belnr IN so_beln1.
    APPEND ls_x007 TO gt_007.
    CLEAR ls_x007.
  ENDLOOP.
ENDFORM.                    " F_FILTER_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_BSAS
*&---------------------------------------------------------------------*
FORM f_get_data_bsas TABLES ft_xbkpf  TYPE ty_xbkpf_tab
                            ft_xbseg  TYPE ty_xbseg_tab.
  TYPES : BEGIN OF ty_bsas,
            bukrs	TYPE bsas-bukrs,
            hkont	TYPE bsas-hkont,
            augdt	TYPE bsas-augdt,
            augbl	TYPE bsas-augbl,
            zuonr	TYPE bsas-zuonr,
            gjahr	TYPE bsas-gjahr,
            belnr	TYPE bsas-belnr,
            buzei	TYPE bsas-buzei,
          END OF ty_bsas.

  DATA : lr_augdt TYPE RANGE OF augdt,
         ls_augdt LIKE LINE OF lr_augdt.

  DATA : lt_bsas TYPE STANDARD TABLE OF ty_bsas,
         ls_bsas LIKE LINE OF lt_bsas,
         lt_bseg TYPE STANDARD TABLE OF ty_xbseg,
         ls_bseg LIKE LINE OF lt_bseg,
         lt_006  TYPE STANDARD TABLE OF zdgfidt006,
         ls_006  TYPE zdgfidt006,
         ls_007  LIKE LINE OF gt_007.

  CONCATENATE p_gjahr gv_monat '01' INTO ls_augdt-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ls_augdt-low
    IMPORTING
      last_day_of_month = ls_augdt-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  ls_augdt-sign   = 'I'.
  ls_augdt-option = 'BT'.
  APPEND ls_augdt TO lr_augdt.

  CLEAR lt_006[].
  SELECT *
    FROM zdgfidt006
    INTO TABLE lt_006.

  SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
    FROM bsas
    INTO TABLE lt_bsas
    WHERE bukrs = p_bukrs
      AND augdt IN lr_augdt.
*      AND belnr = '0410005585'.

  LOOP AT lt_bsas INTO ls_bsas.
    IF ls_bsas-augbl = ls_bsas-belnr.
      DELETE TABLE lt_bsas FROM ls_bsas.
      CONTINUE.
    ENDIF.
    CLEAR ls_006.
    READ TABLE lt_006 INTO ls_006
                      WITH KEY hkont = ls_bsas-hkont.
    IF sy-subrc = 0.
      DELETE TABLE lt_bsas FROM ls_bsas.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  SORT lt_bsas BY belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_bsas COMPARING belnr gjahr.
  IF lt_bsas[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr monat waers
      FROM bkpf
      INTO TABLE ft_xbkpf
      FOR ALL ENTRIES IN lt_bsas
      WHERE bukrs = lt_bsas-bukrs
        AND belnr = lt_bsas-belnr
        AND gjahr = lt_bsas-gjahr.

    SELECT bukrs belnr gjahr buzei augdt shkzg gsber dmbtr wrbtr
      sgtxt hkont
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE ft_xbseg
      FOR ALL ENTRIES IN lt_bsas
      WHERE bukrs = lt_bsas-bukrs
        AND belnr = lt_bsas-belnr
        AND gjahr = lt_bsas-gjahr.
  ENDIF.

  SORT ft_xbseg BY hkont.
  LOOP AT ft_xbseg INTO ls_bseg.
    ls_007-bukrs = ls_bseg-bukrs.
    ls_007-gsber = ls_bseg-gsber.
    ls_007-monat = gv_monat.
    ls_007-gjahr = p_gjahr.
    ls_007-belnr = ls_bseg-belnr.
    ls_007-hkont = ls_bseg-hkont.
    ls_007-shkzg = ls_bseg-shkzg.
    ls_007-waers = gv_local_curr.
    ls_007-wrbtr = ls_bseg-wrbtr.
    ls_007-dmbtr = ls_bseg-dmbtr.
    APPEND ls_007 TO gt_007.
    CLEAR ls_007.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_BSAS

*&---------------------------------------------------------------------*
*&      Form  F_F4_VERSN
*&---------------------------------------------------------------------*
FORM f_f4_versn  USING    fu_field.
  DATA : BEGIN OF lt_cashflow OCCURS 0,
           versn TYPE zdgfidt003-versn,
           vstxt TYPE zdgfidt003-vstxt,
         END OF lt_cashflow.

  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0.

  SELECT *
    FROM zdgfidt003
    INTO CORRESPONDING FIELDS OF TABLE lt_cashflow.

  ASSIGN lt_cashflow[] TO <fs_tab>.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = 'VERSN'
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_field
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback
