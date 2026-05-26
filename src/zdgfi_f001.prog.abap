*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : FFI 09
*& Functional Designer   : Yanti Siwan
*& ABAP Developer        : Win Wiranata
*& Initial Creation Date : 25.05.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& This program will print process order.
*&
*&
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
*& 01.05.2012  DGABAP01  ABCD905770   01       Initial creation
*&
*&----------------------------------------------------------------------------*
REPORT  zdgfi_f001.

* Please add comments before any group of codes and data declarations,
* and subroutine calls.

*-----------------------------------------------------------------------------*
* T A B L E S
*-----------------------------------------------------------------------------*
* Tables are usually used to define work-area for select-options in selection
* screen, or for NAST header
*-----------------------------------------------------------------------------*

TABLES: bkpf.
*-----------------------------------------------------------------------------*
* T Y P E S
*-----------------------------------------------------------------------------*
* Declare all Type Pools, Standard Types, and Table Types here.
* Naming convention: ty_xxx (types)
*                    ty_xxx_tab (table types)
*-----------------------------------------------------------------------------*

TYPES: BEGIN OF ty_bkpf,
         belnr TYPE bkpf-belnr,
         bukrs TYPE bkpf-bukrs,
         gjahr TYPE bkpf-gjahr,
         xblnr TYPE bkpf-xblnr,
         waers TYPE bkpf-waers,
         bldat TYPE bkpf-bldat,
         budat TYPE bkpf-budat,
         stblg TYPE bkpf-stblg,
       END OF ty_bkpf,

       BEGIN OF ty_bseg,
         bukrs TYPE bseg-bukrs,
         gjahr TYPE bseg-gjahr,
         belnr TYPE bseg-belnr,
         buzei TYPE bseg-buzei,
         koart TYPE bseg-koart,
         sgtxt TYPE bseg-sgtxt,
         wrbtr TYPE bseg-wrbtr,
         kunnr TYPE bseg-kunnr,
         mwart TYPE bseg-mwart,
         hkont TYPE bseg-hkont,
         saknr TYPE vbsegs-saknr,
         mwskz TYPE bseg-mwskz,
         vbund TYPE bseg-vbund,
         bschl TYPE bseg-bschl,
         zuonr TYPE bseg-zuonr,
         shkzg TYPE bseg-shkzg,
       END OF ty_bseg,

       BEGIN OF ty_zgdtxdt0104,
         bukrs TYPE zgdtxdt0104-bukrs,
         brnch TYPE zgdtxdt0104-brnch,
         hkont TYPE zgdtxdt0104-hkont,
         blart TYPE zgdtxdt0104-blart,
       END OF ty_zgdtxdt0104,

       BEGIN OF ty_adrc,
         addrnumber TYPE adrc-addrnumber,
         name1      TYPE adrc-name1,
         str_suppl1 TYPE ad_strspp1,
         str_suppl2 TYPE ad_strspp2,
         str_suppl3 TYPE ad_strspp3,
         location   TYPE ad_lctn,
         street     TYPE adrc-street,
         city1      TYPE adrc-city1,
         post_code1 TYPE adrc-post_code1,
       END OF ty_adrc.

TYPES: ty_adrnr TYPE kna1-adrnr,
       ty_ktokd TYPE kna1-ktokd.

*-----------------------------------------------------------------------------*
* I N T E R N A L   T A B L E S   &   W O R K I N G - A R E A S
*-----------------------------------------------------------------------------*
* Naming convention: gt_xxx (global internal tables)
*                    wa_xxx (global working areas)
*-----------------------------------------------------------------------------*
* BKPF  : FI Document Header,
* BSEG  : FI Document Line Item,
* BSET  : Tax data for FI Line Item.
DATA: gs_bkpf         TYPE ty_bkpf,
      gt_bseg         TYPE STANDARD TABLE OF ty_bseg WITH HEADER LINE,
      gt_zgdtxdt0104  TYPE STANDARD TABLE OF ty_zgdtxdt0104 WITH HEADER LINE,
      wa_bseg         TYPE ty_bseg,
      gs_adrc         TYPE ty_adrc,
      gv_adrnr        TYPE ty_adrnr,
      gv_ktokd        TYPE ty_ktokd,
      gv_vtotal       TYPE bseg-wrbtr,
      gv_stotal(50)   TYPE c,
      gv_ttd(40)      TYPE c,
      gv_isreprint(1) TYPE c,
      gv_spell        LIKE spell OCCURS 0 WITH HEADER LINE,
      gv_amount       LIKE spell-number,
      "gt_kna1 TYPE STANDARD TABLE OF kna1 WITH HEADER LINE,
      "wa_debitnote TYPE ty_debitnote,
      return          TYPE STANDARD TABLE OF bdcmsgcoll,
      gs_header       TYPE zdgfish_f001,
      gt_item         TYPE STANDARD TABLE OF zdgfisd_f001,
      gt_item1        TYPE STANDARD TABLE OF zdgfisd_f001,
      wa_item         TYPE zdgfisd_f001.


DATA: wa_address TYPE zdgfi_f001_add_struct.

"gt_sffi_09 type standard table of zdgffis_09 with header line.

*DATA: BEGIN OF gt_fish_01 OCCURS 0.
*        INCLUDE STRUCTURE zdgfish_f001.
*DATA: END OF gt_fish_01.
*
*DATA: BEGIN OF gt_fisd_01 OCCURS 0.
*        INCLUDE STRUCTURE zdgfisd_f001.
*DATA: END OF gt_fisd_01.


*-----------------------------------------------------------------------------*
* G L O B A L   V A R I A B L E S
*-----------------------------------------------------------------------------*
* Naming convention: gv_xxxx (variables)
*                    gs_xxxx (structures)
*-----------------------------------------------------------------------------*
DATA: d_petugas  LIKE zgdtxdt0005-petugas,
      d_jabat    LIKE zgdtxdt0005-jabat,
      d_petugas1 LIKE zgdtxdt0005-petugas,
      d_jabat1   LIKE zgdtxdt0005-jabat,
      d_petugas2 LIKE zgdtxdt0005-petugas2,
      d_jabat2   LIKE zgdtxdt0005-jabat2,
      d_petugas3 LIKE zgdtxdt0005-nameadm,
      d_jabat3   LIKE zgdtxdt0005-jabatadm,
      d_brnch    LIKE zgdtxdt0005-brnch,
      d_object   LIKE zgdtxdt0005-objrange.

DATA: va_subrc   TYPE sy-subrc,
      va_error   TYPE i,
      va_process TYPE sy-subrc.

DATA: gv_nomor LIKE zfgsnomor-nomor,
      gv_gsber LIKE zfgsnomor-gsber,
      gv_vbund LIKE bseg-vbund.

*-----------------------------------------------------------------------------*
* O B J E C T S
*-----------------------------------------------------------------------------*
* Object class definitions
* Naming convention: o_xxxx
*-----------------------------------------------------------------------------*



*-----------------------------------------------------------------------------*
* R A N G E
*-----------------------------------------------------------------------------*
* Naming convention: r_xxxx TYPE RANGE OF xxxx
*-----------------------------------------------------------------------------*
RANGES: r_ktokd    FOR kna1-ktokd.

DATA : gs_003   TYPE zgdtxdt0003.




*-----------------------------------------------------------------------------*
* C O N S T A N T S
*-----------------------------------------------------------------------------*
* Naming convention: c_xxxxx
*-----------------------------------------------------------------------------*

CONSTANTS: c_smartform_name  TYPE tdsfname      VALUE 'ZDGFI_001A'.
CONSTANTS: c_smartform_nameb TYPE tdsfname      VALUE 'ZDGFI_001B'.
CONSTANTS: c_smartform_namec TYPE tdsfname      VALUE 'ZDGFI_001C'.
CONSTANTS: c_smartform_nameanew  TYPE tdsfname      VALUE 'ZDGFI_001A_NEW'.

*-----------------------------------------------------------------------------*
* S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs   TYPE bkpf-bukrs OBLIGATORY.                   " Company Code
PARAMETERS: p_belnr   TYPE bkpf-belnr OBLIGATORY.                   " Document Number
PARAMETERS: p_gjahr   TYPE bkpf-gjahr OBLIGATORY.                   " Fiscal Year
PARAMETERS: p_due     TYPE sy-datum.                                " Due Date

SELECTION-SCREEN SKIP 1.
PARAMETERS: pa_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X' MODIF ID dis.

*PARAMETERS: p_ttd(40) TYPE c OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: rb_prt   RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND ra1,   " Print
            rb_reprt RADIOBUTTON GROUP g1.                                " Reprint
*SELECT-OPTIONS: so_belnr FOR bkpf-belnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF SCREEN 1100 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 3(20) p_jabat1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 3(20) p_jabat2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
PARAMETERS: p_custom  LIKE zgdtxdt0005-petugas.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_stceg   LIKE bseg-stceg MODIF ID pzu.
SELECTION-SCREEN END OF SCREEN 1100.
*
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
*PARAMETER:      cb_addit AS CHECKBOX DEFAULT space USER-COMMAND addi.
*SELECT-OPTIONS: so_umskz FOR bsik-umskz MODIF ID id1,   "Special GL Indicator
*                so_gjahr FOR bsik-gjahr MODIF ID id1,   "Fiscal Year
*                so_zuonr FOR bsik-zuonr MODIF ID id1,   "Assignment
*                so_bldat FOR bsik-bldat MODIF ID id1,   "Document Date
*                so_waers FOR tcurc-waers MODIF ID id1,  "Currency
*                so_blart FOR bkpf-blart MODIF ID id1,   "Document Type
*                so_xblnr FOR bkpf-xblnr MODIF ID id1,   "Reference
*                so_prctr FOR bsik-prctr MODIF ID id1,   "Profit Center
*                so_augbl FOR bsik-augbl MODIF ID id1,   "Clearing Document Number
*                so_bschl FOR bsik-bschl MODIF ID id1.   "Posting Key
*SELECTION-SCREEN SKIP.
*PARAMETERS:     rb_open RADIOBUTTON GROUP g1,
*                p_open1 TYPE bsik-augdt DEFAULT sy-datum,
*                rb_clr  RADIOBUTTON GROUP g1,
*                p_clr1 TYPE bsik-augdt DEFAULT sy-datum.
*SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.

*-----------------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
* Define selection screen validation
*-----------------------------------------------------------------------------*
AT SELECTION-SCREEN.


AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN rb_reprt.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'DIS'.
            screen-active = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

  IF p_bukrs = '8040'.
    LOOP AT SCREEN.
      IF screen-group1 = 'PZU'.
        screen-active  = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'PZU'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*-----------------------------------------------------------------------------*
* S T A R T - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* Start-of-Selection should only be a list of subroutines (for retreiving and
* calculating data) and high level IF conditions, so that we can get the big
* picture of the program and we can drill-down specific process in the
* subroutines.
*-----------------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM finitdata.
  CASE p_bukrs.
    WHEN '8230' OR '8040' OR '8360'.
      PERFORM f_get_data CHANGING va_process.
    WHEN '8050' OR '8800' OR '8020' OR '8070' OR '8190'.
      PERFORM fgetdata CHANGING va_process.
    WHEN '8380'.
      PERFORM f_get_data CHANGING va_process.
    WHEN OTHERS.
  ENDCASE.

  IF va_process IS INITIAL.
    IF rb_prt = 'X' AND gs_bkpf-xblnr <> ''.
      va_error  = 1.
      MESSAGE i000(zab) WITH 'Laporan sudah pernah diprint'.
    ELSEIF rb_reprt = 'X' AND gs_bkpf-xblnr = ''.
      va_error  = 1.
      MESSAGE i000(zab) WITH 'Laporan belum pernah diprint'.
    ENDIF.
  ELSE.
    CASE va_process.
      WHEN 3.
        va_error  = 3.
        MESSAGE i000(zab) WITH 'FP belum diproses'.
      WHEN OTHERS.
        va_error  = 1.
        MESSAGE i000(zab) WITH 'Data tidak ditemukan'.
    ENDCASE.
  ENDIF.

  IF va_error IS INITIAL.
    PERFORM f_populate_header.
    PERFORM f_populate_item.
    IF gt_item[] IS INITIAL.
      MESSAGE s001(oiuh) DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    CASE p_bukrs.
      WHEN '8020' OR '8070'.
      WHEN OTHERS.
        PERFORM f_popup_signer CHANGING gs_header-ttd va_subrc.
    ENDCASE.

    IF va_subrc IS INITIAL.
      CASE p_bukrs.
        WHEN '8020' OR '8070'.
          PERFORM f_print_smartforms USING c_smartform_nameb.
        WHEN '8360'.
          PERFORM f_print_smartforms USING c_smartform_namec.
        WHEN '8190'.
          PERFORM f_print_smartforms USING c_smartform_nameanew.
        WHEN OTHERS.
          PERFORM f_print_smartforms USING c_smartform_name.
      ENDCASE.
    ENDIF.
  ELSE.
    MESSAGE s001(oiuh) DISPLAY LIKE 'E'.
  ENDIF.

*-----------------------------------------------------------------------------*
* E N D - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* End-of-selection will be a list (and high level IF condition) for generating
* and displaying report and it's features (after data collection).
*-----------------------------------------------------------------------------*
*  IF NOT gt_report[] IS INITIAL.
*
**   Build Field Catalog
*    PERFORM f_build_alv_fieldcat USING    c_alv_structure
*                                 CHANGING t_fldcat.
*
**   Set Layout
*    PERFORM f_set_alv_layout_data USING    t_report
*                                  CHANGING wa_layout.
*
**   Display Report
*    PERFORM f_display_reports USING c_alv_structure
*                                    wa_layout
*                                    t_fldcat
*                                    t_report.
*
*  ELSE.
*
**   No record found
*    MESSAGE s001(oiuh) DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*
*  ENDIF.
*
** Print Smartforms
*  PERFORM f_print_smartforms USING c_smartform_name.


*-----------------------------------------------------------------------------*
* S U B - R O U T I N E S
*-----------------------------------------------------------------------------*
* Guidelines:
* - subroutines should never be too long (only 1 function/process)
* - if there is a function/process that are needed more than once, make a
*   subroutine with parameters for that to avoid redundancy codes
* - subroutines (to divide program's logic) that are called only once from
*   Start-of-selection or End-of-selection (or screens) need not use
*   parameters.
* - Naming convention: lt_xxx  (local tables)
* -                    lwa_xxx (local working areas)
* -                    lv_xxx  (local variables)
* -                    p_xxxx  (parameters)
* -                    pt_xxx  (table parameters)
*-----------------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  f_display_reports
*&---------------------------------------------------------------------*
*       Display ALV Report
*----------------------------------------------------------------------*
*FORM f_display_reports USING p_structure_name TYPE dd02l-tabname
*                             pwa_layout TYPE lvc_s_layo
*                             pt_fldcat  TYPE lvc_t_fcat
*                             pt_report  TYPE ty_report_tab.
*
** Display ALV
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
*    EXPORTING
*      i_callback_program      = sy-repid
**      i_callback_top_of_page  =
*      i_structure_name        = p_structure_name
*      is_layout_lvc           = pwa_layout
*      it_fieldcat_lvc         = pt_fldcat[]
**      i_save                  =
*    TABLES
*      t_outtab                = pt_report[]
*    EXCEPTIONS
*      program_error           = 1
*      OTHERS                  = 2.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*ENDFORM.                    " f_display_reports


*&---------------------------------------------------------------------*
*&      Form  f_print_smartforms
*&---------------------------------------------------------------------*
*       Print the smartforms
*----------------------------------------------------------------------*
FORM f_print_smartforms USING p_formname TYPE tdsfname.

  DATA:
    l_funcname         TYPE tdsfname,
    l_total_pages      TYPE tdsffpage,
    lwa_control_option TYPE ssfctrlop,
    lwa_output_option  TYPE ssfcompop,
    lwa_doc_info       TYPE ssfcrespd,
    lwa_output_info    TYPE ssfcrescl.

* Determine Smartform function module name
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_formname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
*   Message has been maintained inside the function module
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF rb_prt IS NOT INITIAL.
    IF pa_disp IS INITIAL.
      lwa_output_option-tdnoprev = 'X'.
    ELSE.
      lwa_output_option-tdnoprint = 'X'.
    ENDIF.
  ENDIF.


  IF p_bukrs = '8190'.
    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = 'X'
        sf_header          = gs_header
        gv_stceg           = pa_stceg
        gs_address         = wa_address
      TABLES
        gt_detail          = gt_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
*       CONTROL_PARAMETERS =
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
*       OUTPUT_OPTIONS     =
*       sf_form_1771       = wa_form_1771
*       sf_form_lampiran1  = wa_form_lampiran1
*       sf_form_lampiran2  = wa_form_lampiran2
*       sf_form_lampiran4  = wa_form_lampiran4
*       sf_form_lampiran567        = wa_form_lampiran567
*       item               = gt_item
*       account_assignment = gt_account_assignment
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
      .

  ELSE.
    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = 'X'
        sf_header          = gs_header
        gv_stceg           = pa_stceg
      TABLES
        gt_detail          = gt_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
*       CONTROL_PARAMETERS =
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
*       OUTPUT_OPTIONS     =
*       sf_form_1771       = wa_form_1771
*       sf_form_lampiran1  = wa_form_lampiran1
*       sf_form_lampiran2  = wa_form_lampiran2
*       sf_form_lampiran4  = wa_form_lampiran4
*       sf_form_lampiran567        = wa_form_lampiran567
*       item               = gt_item
*       account_assignment = gt_account_assignment
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
      .
  ENDIF.
  IF sy-subrc <> 0.


    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "f_print_smartforms
*&---------------------------------------------------------------------*
*&      Form  FGETDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fgetdata CHANGING fc_subrc.
* Get Document Header
  CLEAR gs_bkpf.

  IF p_bukrs = '8020' OR p_bukrs = '8070'.
    SELECT SINGLE belnr bukrs gjahr xblnr waers bldat budat stblg
      INTO gs_bkpf FROM bkpf
      WHERE bukrs = p_bukrs
        AND belnr = p_belnr
        AND gjahr = p_gjahr
        AND stblg = space.

    fc_subrc  = sy-subrc.

* Get Document Item
    CLEAR gt_bseg.
    SELECT bukrs gjahr belnr buzei koart sgtxt wrbtr kunnr
           mwart hkont saknr saknr vbund bschl zuonr shkzg
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM bseg
     WHERE bukrs = p_bukrs
       AND belnr = p_belnr
       AND gjahr = p_gjahr
*       AND bschl = '01'.
       AND bschl IN ('01','11').

  ELSE.
    IF p_bukrs = '8190'.
      SELECT SINGLE bukrs, gjahr, belnr, buzei, hkont
        INTO @DATA(ls_bseg)
        FROM bseg WHERE bukrs = @p_bukrs
                    AND gjahr = @p_gjahr
                    AND belnr = @p_belnr
                    AND hkont = '0315300210'.
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM zgdtxdt0003
          INTO CORRESPONDING FIELDS OF gs_003
          WHERE bukrs = p_bukrs
            AND vbeln = p_belnr.
        IF sy-subrc <> 0.
          fc_subrc = 3.
        ENDIF.
      ENDIF.

      IF fc_subrc = 0.
*      ADD SELECT ADDRESS
        SELECT SINGLE * INTO @wa_address FROM zdgfi_f001_view( p_vkbur = 1900 ).
*        SHIFT wa_address-street LEFT DELETING LEADING space.
*      wa_address-street1 = wa_address-street.
      ENDIF.
    ENDIF.

    IF fc_subrc = 0.
      SELECT SINGLE belnr bukrs gjahr xblnr waers bldat budat stblg
        INTO gs_bkpf FROM bkpf
        WHERE bukrs = p_bukrs
          AND belnr = p_belnr
          AND gjahr = p_gjahr.

      fc_subrc  = sy-subrc.

* Get Document Item
      CLEAR gt_bseg.
      SELECT bukrs gjahr belnr buzei koart sgtxt wrbtr kunnr
             mwart hkont saknr saknr vbund bschl zuonr shkzg
        INTO CORRESPONDING FIELDS OF TABLE gt_bseg
        FROM bseg
       WHERE bukrs = p_bukrs
         AND belnr = p_belnr
*{   REPLACE        P01K910745                                        1
*\       AND gjahr = p_gjahr.
         "Start Change 15032024 RZL
         AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
      "End Change 15032024 RZL
*}   REPLACE
      "AND koart = 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                    " FGETDATA


*&---------------------------------------------------------------------*
*&      Form  f_populate_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_header.

  CLEAR gs_header.
  gs_header-bukrs     = p_bukrs.
  gs_header-gjahr     = p_gjahr.
  gs_header-belnr     = p_belnr.
  gs_header-nocoretax = gs_003-nocoretax.
  gs_header-waers     = gs_bkpf-waers.
  gs_header-xblnr     = gs_bkpf-xblnr.
  gs_header-budat     = gs_bkpf-budat.

  " Jika Print Get Debit Note Number
  IF rb_prt = 'X'.
    CASE p_bukrs.
      WHEN  '8020' OR '8070'.
        PERFORM f_get_next_number_ptt.

      WHEN OTHERS.
        PERFORM f_get_next_number USING 'ZTDGDNT001'
                                  CHANGING gs_header-xblnr.
        CONCATENATE gs_bkpf-bldat(4) '/' gs_bkpf-bldat+4(2) '/' gs_header-xblnr INTO gs_header-xblnr.
    ENDCASE.

    IF pa_disp IS INITIAL.
      PERFORM update_gsnomor.
      PERFORM updatereferencedoc USING gs_header-xblnr 'FB02'.
      PERFORM updatereferencedoc USING gs_header-xblnr 'FB09'. "8020 and 8070 only
    ENDIF.
  ENDIF.

* Populate Customer Number
  READ TABLE gt_bseg INTO wa_bseg INDEX 1.
  IF sy-subrc = 0.
    gs_header-kunnr = wa_bseg-kunnr.

    CASE wa_bseg-bschl.
      WHEN '01'.
        gs_header-judul = 'DEBIT NOTE'.
      WHEN '11'.
        gs_header-judul = 'KREDIT NOTE'.
    ENDCASE.

* Get Customer Address
    CLEAR gv_adrnr.
    SELECT SINGLE adrnr INTO gv_adrnr FROM kna1 WHERE kunnr = wa_bseg-kunnr.
    SELECT SINGLE ktokd INTO gv_ktokd FROM kna1 WHERE kunnr = wa_bseg-kunnr.

    SELECT SINGLE addrnumber
                  name1
                  str_suppl1
                  str_suppl2
                  str_suppl3
                  location
                  street
                  city1
                  post_code1
             INTO gs_adrc FROM adrc
            WHERE addrnumber = gv_adrnr.

    gs_header-adrnr      = gs_adrc-addrnumber.
    gs_header-name1      = gs_adrc-name1.
*    gs_header-street     = gs_adrc-street.
    CONCATENATE gs_adrc-str_suppl1 gs_adrc-str_suppl2
                gs_adrc-str_suppl3 gs_adrc-location
           INTO gs_header-street
    SEPARATED BY space.
    gs_header-city1      = gs_adrc-city1.
    gs_header-post_code1 = gs_adrc-post_code1.

    SELECT SINGLE petugas INTO gs_header-ttd FROM zgdtxdt0005 WHERE bukrs = p_bukrs.

  ENDIF.
ENDFORM.                    "f_populate_header


*&---------------------------------------------------------------------*
*&      Form  f_populate_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_item.
  DATA: lv_lines    LIKE STANDARD TABLE OF tline WITH HEADER LINE,
        id          LIKE thead-tdid,
        tname       LIKE thead-tdname,
        tdobject    LIKE thead-tdobject,
        lv_notfound.

  DATA : lv_wrbtr   TYPE p DECIMALS 4.

  CLEAR gt_item[].
  CLEAR gv_vtotal.
  SORT gt_bseg BY bukrs hkont.
  SORT gt_zgdtxdt0104 BY bukrs hkont.
  LOOP AT gt_bseg INTO wa_bseg.
    IF wa_bseg-koart = 'S' OR
     ( wa_bseg-koart = 'D' AND wa_bseg-bukrs = '8020' ) OR
     ( wa_bseg-koart = 'D' AND wa_bseg-bukrs = '8070' ).
      CLEAR wa_item.
      wa_item-bukrs = wa_bseg-bukrs.
      wa_item-gjahr = wa_bseg-gjahr.
      wa_item-belnr = wa_bseg-belnr.
      wa_item-buzei = wa_bseg-buzei.
      wa_item-koart = wa_bseg-koart.
      wa_item-waers = gs_bkpf-waers.
      wa_item-wrbtr = wa_bseg-wrbtr.

      CASE wa_bseg-mwskz.
        WHEN 'A0'.
          wa_item-wrbtr = wa_bseg-wrbtr.
          wa_item-sgtxt = wa_bseg-sgtxt.

        WHEN 'K2'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-sgtxt = 'VAT Out 10%'.
            CASE wa_bseg-bukrs.
              WHEN '8040'.
                PERFORM f_rounding USING wa_bseg-wrbtr 10 110 '-' ''
                                   CHANGING wa_item-wrbtr.
              WHEN OTHERS.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 10 / 110 ).
            ENDCASE.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
            CASE wa_bseg-bukrs.
              WHEN '8040'.
                PERFORM f_rounding USING wa_bseg-wrbtr 100 110 '+' ''
                                   CHANGING wa_item-wrbtr.
              WHEN OTHERS.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 110 ).
            ENDCASE.
          ENDIF.

        WHEN 'K5'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
*            wa_item-sgtxt = 'VAT Out 11%'.
            wa_item-sgtxt = 'VAT Out'.
*            CASE wa_bseg-bukrs.
*              WHEN '8040'.
            PERFORM f_rounding_tax USING wa_bseg-wrbtr 11 111 '-'
                                         wa_bseg-mwskz
                                   CHANGING wa_item-wrbtr.
*              WHEN OTHERS.
*                wa_item-wrbtr = wa_bseg-wrbtr * ( 11 / 111 ).
*            ENDCASE.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
*            CASE wa_bseg-bukrs.
*              WHEN '8040'.
            PERFORM f_rounding USING wa_bseg-wrbtr 100 111 '+' ''
                               CHANGING wa_item-wrbtr.
*              WHEN OTHERS.
*                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 111 ).
*            ENDCASE.
          ENDIF.

        WHEN 'K8'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-sgtxt = 'VAT Out 12%'.
*            CASE wa_bseg-bukrs.
*              WHEN '8040'.
            PERFORM f_rounding_tax USING wa_bseg-wrbtr 12 112 '-'
                                         wa_bseg-mwskz
                                   CHANGING wa_item-wrbtr.
*              WHEN OTHERS.
*                wa_item-wrbtr = wa_bseg-wrbtr * ( 11 / 111 ).
*            ENDCASE.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
*            CASE wa_bseg-bukrs.
*              WHEN '8040'.
            PERFORM f_rounding USING wa_bseg-wrbtr 100 112 '+' ''
                               CHANGING wa_item-wrbtr.
*              WHEN OTHERS.
*                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 111 ).
*            ENDCASE.
          ENDIF.

        WHEN 'K3'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-sgtxt = 'VAT Out 1%'.
            wa_item-wrbtr = wa_bseg-wrbtr / 101.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
            wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 101 ).
          ENDIF.

        WHEN 'K7'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-sgtxt = 'VAT Out 1.1%'.
            wa_item-wrbtr = wa_bseg-wrbtr * 10 / 1011.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
            wa_item-wrbtr = wa_bseg-wrbtr * ( 1000 / 1011 ).
          ENDIF.

        WHEN 'K9'.
          READ TABLE gt_zgdtxdt0104 WITH KEY bukrs = wa_bseg-bukrs
                                             hkont = wa_bseg-hkont
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            wa_item-sgtxt = 'VAT Out 1.2%'.
            wa_item-wrbtr = wa_bseg-wrbtr * 10 / 1012.
            wa_item-buzei = '999'.
          ELSE.
            wa_item-sgtxt = wa_bseg-sgtxt.
            wa_item-wrbtr = wa_bseg-wrbtr * ( 1000 / 1012 ).
          ENDIF.

        WHEN OTHERS.
          IF p_bukrs = '8380'.
            IF wa_bseg-mwskz = 'A1'.
              IF wa_bseg-hkont(2) = '08'.
                wa_item-sgtxt = 'VAT Out 10%'.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 10 / 110 ).
                wa_item-buzei = '999'.
              ELSE.
                wa_item-sgtxt = wa_bseg-sgtxt.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 110 ).
              ENDIF.
            ELSEIF wa_bseg-mwskz = 'A3'.
              IF wa_bseg-hkont(2) = '08'.
*                wa_item-sgtxt = 'VAT Out 11%'.
                wa_item-sgtxt = 'VAT Out'.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 10 / 111 ).
                wa_item-buzei = '999'.
              ELSE.
                wa_item-sgtxt = wa_bseg-sgtxt.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 111 ).
              ENDIF.
            ELSEIF wa_bseg-mwskz = 'A4'.
              IF wa_bseg-hkont(2) = '08'.
                wa_item-sgtxt = 'VAT Out 12%'.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 10 / 112 ).
                wa_item-buzei = '999'.
              ELSE.
                wa_item-sgtxt = wa_bseg-sgtxt.
                wa_item-wrbtr = wa_bseg-wrbtr * ( 100 / 112 ).
              ENDIF..
            ELSE.
              wa_item-sgtxt = wa_bseg-sgtxt.
              wa_item-wrbtr = wa_bseg-wrbtr.
            ENDIF.
          ELSE.
            IF wa_bseg-mwart EQ 'A'.
              wa_item-sgtxt = 'VAT Out'.
              wa_item-buzei = '999'.
            ELSE.
              wa_item-sgtxt = wa_bseg-sgtxt.
            ENDIF.
            wa_item-wrbtr = wa_bseg-wrbtr.
          ENDIF.
      ENDCASE.

      IF p_bukrs = '8190'.
        IF wa_bseg-shkzg = 'S'.
          wa_item-wrbtr = wa_item-wrbtr * -1.
        ENDIF.
      ENDIF.

      gv_vtotal = gv_vtotal + wa_item-wrbtr.

      APPEND wa_item TO gt_item.
    ENDIF.
  ENDLOOP.

  SORT gt_item BY bukrs belnr gjahr buzei.

  """"""""""""""""""""""""""""""""""""""""
  "   Get Long Description for Account   "
  """"""""""""""""""""""""""""""""""""""""
  gt_item1[]  = gt_item[].

  LOOP AT gt_item1 INTO wa_item.
    id = '0001'.
    tdobject = 'DOC_ITEM'.
    CONCATENATE p_bukrs p_belnr p_gjahr wa_item-buzei INTO tname. "=   "'1820000009'.
    CLEAR lv_notfound.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = id
        language                = sy-langu
        name                    = tname
        object                  = tdobject
      TABLES
        lines                   = lv_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.

    DATA: lv_loop TYPE i.

    IF sy-subrc EQ 0.
      lv_loop = 1.
      DO 5 TIMES.
        READ TABLE lv_lines INDEX lv_loop.
        CHECK sy-subrc EQ 0.
        wa_item-bukrs = p_bukrs.
        wa_item-gjahr = p_gjahr.
        wa_item-belnr = p_belnr.
        wa_item-buzei = 99.
        wa_item-koart = ''.
        wa_item-waers = ''.
        wa_item-wrbtr = 0.
        IF sy-subrc = 0.
          wa_item-sgtxt = lv_lines-tdline.
        ELSE.
          wa_item-sgtxt = ''.
        ENDIF.
        APPEND wa_item TO gt_item.
        lv_loop = lv_loop + 1.
      ENDDO.
*    ELSE.
*      DO 5 TIMES.
*        wa_item-bukrs = p_bukrs.
*        wa_item-gjahr = p_gjahr.
*        wa_item-belnr = p_belnr.
*        wa_item-buzei = 99.
*        wa_item-koart = ''.
*        wa_item-waers = ''.
*        wa_item-wrbtr = 0.
*        wa_item-sgtxt = ''.
*        APPEND wa_item TO gt_item.
*      ENDDO.
    ENDIF.
  ENDLOOP.

  gs_header-vtotal = gv_vtotal.
  PERFORM sayamount USING gs_header-vtotal gs_header-waers.

ENDFORM.                    "f_populate_item


*&---------------------------------------------------------------------*
*&      Form  f_get_next_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_OBJECT  text
*      -->FC_NOMOR   text
*----------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_object
                        CHANGING fc_nomor.
  DATA: lw_nriv    LIKE nriv,
        ld_nrlevel TYPE nriv-tonumber.

  IF pa_disp EQ 'X'.
    SELECT SINGLE *
      FROM nriv
      INTO lw_nriv
      WHERE object      = fu_object  AND
            subobject   = p_bukrs    AND
            nrrangenr   = '01'       AND
            toyear      = p_gjahr.
    PERFORM f_delete_leading_zero USING lw_nriv-nrlevel
                                  CHANGING fc_nomor.

  ELSE.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = fu_object
        subobject               = p_bukrs
        toyear                  = p_gjahr
      IMPORTING
        number                  = fc_nomor
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
  ENDIF.
ENDFORM.                    "f_get_next_number


*&---------------------------------------------------------------------*
*&      Form  UpdateReferenceDoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM updatereferencedoc USING fu_nomor fu_tcode.
  CALL FUNCTION 'ZDGFI_ACC_DOCUMENT_CHANGE'
    EXPORTING
      belnr  = p_belnr
      bukrs  = p_bukrs
      gjahr  = p_gjahr
*     MODE   = 'N'
      xblnr  = fu_nomor
      tcode  = fu_tcode
    TABLES
      return = return.

ENDFORM.                    "UpdateReferenceDoc

*&---------------------------------------------------------------------*
*&      Form  F_CUSTOMER_ACCGRP
*&---------------------------------------------------------------------*
FORM f_customer_accgrp  USING    fu_ktokd.
  r_ktokd-low      = fu_ktokd.
  r_ktokd-sign     = 'I'.
  r_ktokd-option   = 'EQ'.
  APPEND r_ktokd.
ENDFORM.                    " F_CUSTOMER_ACCGRP
*&---------------------------------------------------------------------*
*&      Form  FINITDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM finitdata .
  PERFORM f_customer_accgrp USING 'FAFC'.
  PERFORM f_customer_accgrp USING 'FAFN'.
  PERFORM f_customer_accgrp USING 'FARN'.
  PERFORM f_customer_accgrp USING 'FINC'.
  PERFORM f_customer_accgrp USING 'FORG'.
  PERFORM f_customer_accgrp USING 'FORN'.
  PERFORM f_customer_accgrp USING 'FOTA'.
  PERFORM f_customer_accgrp USING 'FOTN'.
  PERFORM f_customer_accgrp USING 'FOTT'.

* Get G/L Account for VAT Account
  CLEAR gt_zgdtxdt0104.
  SELECT bukrs brnch hkont blart
    FROM zgdtxdt0104
    INTO TABLE gt_zgdtxdt0104
    WHERE bukrs EQ p_bukrs.

  CASE p_bukrs.
    WHEN '8020'.
      gv_gsber = '0200'.
    WHEN '8070'.
      gv_gsber = '0700'.
  ENDCASE.
ENDFORM.                    " FINITDATA
*&---------------------------------------------------------------------*
*&      Form  SAYAMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sayamount USING pwrbtr pwaers.

  DATA: lv_language  TYPE sy-langu,
        lv_month(10),
        lt_month     TYPE STANDARD TABLE OF t247 WITH HEADER LINE,
        lv_matauang  TYPE ktext,
        lv_budat     TYPE sy-datum.

  lv_month  = gs_bkpf-bldat+4(2).
  IF pwaers EQ 'IDR'.
    lv_language = 'i'.
    CALL FUNCTION 'ZMONTH_NAME'
      EXPORTING
        month = lv_month
      IMPORTING
        name  = lv_month.
    CONCATENATE gs_bkpf-bldat+6(2) lv_month gs_bkpf-bldat(4) INTO gs_header-bldat SEPARATED BY space.

    IF p_bukrs EQ '8050' OR
      p_bukrs EQ '8800'.
      lv_budat  = gs_bkpf-bldat + 30.
      lv_month = lv_budat+4(2).
      CALL FUNCTION 'ZMONTH_NAME'
        EXPORTING
          month = lv_month
        IMPORTING
          name  = lv_month.
      CONCATENATE lv_budat+6(2) lv_month lv_budat(4) INTO gs_header-due SEPARATED BY space.
    ELSE.
      lv_month = p_due+4(2).
      CALL FUNCTION 'ZMONTH_NAME'
        EXPORTING
          month = lv_month
        IMPORTING
          name  = lv_month.
      CONCATENATE p_due+6(2) lv_month p_due(4) INTO gs_header-due SEPARATED BY space.
    ENDIF.
  ELSE.
    lv_language = 'EN'.
    CALL FUNCTION 'MONTH_NAMES_GET'
      EXPORTING
        language    = lv_language
      TABLES
        month_names = lt_month.
    READ TABLE lt_month WITH KEY mnr = lv_month.
    IF sy-subrc EQ 0.
      lv_month  = lt_month-ltx.
      CONCATENATE gs_bkpf-bldat+6(2) lv_month gs_bkpf-bldat(4) INTO gs_header-bldat SEPARATED BY space.
    ENDIF.

    IF p_bukrs EQ '8050' OR
      p_bukrs EQ '8800'.
      lv_budat  = gs_bkpf-bldat + 30.
      lv_month  = lv_budat+4(2).
      CALL FUNCTION 'MONTH_NAMES_GET'
        EXPORTING
          language    = lv_language
        TABLES
          month_names = lt_month.
      READ TABLE lt_month WITH KEY mnr = lv_month.
      IF sy-subrc EQ 0.
        lv_month  = lt_month-ltx.
        CONCATENATE lv_budat+6(2) lv_month lv_budat(4) INTO gs_header-due SEPARATED BY space.
      ENDIF.
    ELSE.
      lv_month = p_due+4(2).
      CALL FUNCTION 'MONTH_NAMES_GET'
        EXPORTING
          language    = lv_language
        TABLES
          month_names = lt_month.
      READ TABLE lt_month WITH KEY mnr = lv_month.
      IF sy-subrc EQ 0.
        lv_month  = lt_month-ltx.
        CONCATENATE p_due+6(2) lv_month p_due(4) INTO gs_header-due SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount   = pwrbtr
      currency = pwaers
      language = lv_language
    IMPORTING
      in_words = gv_spell.
*                         EXCEPTIONS
*                           NOT_FOUND       = 1
*                           TOO_LARGE       = 2
*                           OTHERS          = 3
  .
  IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR lv_matauang.
    SELECT SINGLE ktext INTO lv_matauang FROM tcurt WHERE spras = 'E' AND waers = pwaers.
    TRANSLATE lv_matauang TO UPPER CASE.
    IF lv_language = 'EN' OR lv_language = 'E'.
      IF gv_spell-decword EQ 'ZERO'.
        CONCATENATE 'Say: ' gv_spell-word lv_matauang INTO gs_header-stotal SEPARATED BY space.
      ELSE.
        CONCATENATE 'Say: ' gv_spell-word 'AND' gv_spell-decword lv_matauang INTO gs_header-stotal SEPARATED BY space.
      ENDIF.
    ELSE.
      TRANSLATE lv_matauang TO UPPER CASE.
      IF p_bukrs = '8020' OR p_bukrs = '8070'.
        CONCATENATE gv_spell-word lv_matauang INTO gs_header-stotal SEPARATED BY space .
      ELSE.
        CONCATENATE 'Terbilang: ' gv_spell-word lv_matauang INTO gs_header-stotal SEPARATED BY space .
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAYAMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_SIGNER
*&---------------------------------------------------------------------*
FORM f_popup_signer CHANGING fc_petugas fc_subrc.

  DATA lw_zgdtxdt0005 LIKE zgdtxdt0005.

***Get signature
  IF p_bukrs = '8380'.
    SELECT SINGLE vatnm vattl vatnm2 vattl2
      FROM zfvatnm
      INTO (p_jabat1, d_jabat1, p_jabat2, d_jabat2)
      WHERE vkorg = p_bukrs.
  ELSE.
    SELECT SINGLE petugas jabat petugas2 jabat2 nameadm jabatadm brnch objrange
           INTO CORRESPONDING FIELDS OF lw_zgdtxdt0005
           FROM zgdtxdt0005
           WHERE bukrs = p_bukrs.
    IF sy-subrc = 0.
      p_jabat1 = lw_zgdtxdt0005-petugas.
      d_jabat1 = lw_zgdtxdt0005-jabat.
      p_jabat2 = lw_zgdtxdt0005-petugas2.
      d_jabat2 = lw_zgdtxdt0005-jabat2.
      p_custom = lw_zgdtxdt0005-nameadm.
      d_jabat3 = lw_zgdtxdt0005-jabatadm.
      d_brnch = lw_zgdtxdt0005-brnch.
      d_object  = lw_zgdtxdt0005-objrange.
    ENDIF.
  ENDIF.

  READ TABLE gt_bseg INDEX 1.
  WRITE gt_bseg-zuonr TO pa_stceg USING EDIT MASK '___.___-__.________'.

  CALL SELECTION-SCREEN 1100 STARTING AT 10 5.

  fc_subrc  = sy-subrc.

  IF sy-subrc EQ 0.
    CASE 'X'.
      WHEN radio1.
        fc_petugas  = p_jabat1.
      WHEN radio2.
        fc_petugas  = p_jabat2.
      WHEN radio3.
        fc_petugas  = p_custom.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_POPUP_SIGNER

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data CHANGING fc_subrc.
  DATA: ld_wrbtr TYPE bseg-wrbtr,
        ld_wrbk2 TYPE bseg-wrbtr,
        ld_wrbk3 TYPE bseg-wrbtr.

  DATA: BEGIN OF lt_bseg OCCURS 0.
          INCLUDE STRUCTURE gt_bseg.
        DATA: END OF lt_bseg.
  DATA: BEGIN OF lt_t007s OCCURS 0,
          kalsm TYPE t007s-kalsm,
          mwskz TYPE t007s-mwskz,
          text1 TYPE t007s-text1,
        END OF lt_t007s.
* Get Document Header
  CLEAR gs_bkpf.
  SELECT SINGLE belnr bukrs gjahr xblnr waers bldat
    FROM vbkpf
    INTO gs_bkpf
    WHERE ausbk EQ p_bukrs  AND
          bukrs EQ p_bukrs  AND
          belnr EQ p_belnr  AND
          gjahr EQ p_gjahr
*{   REPLACE        P01K910536                                        1
*\    %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
  "End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

  fc_subrc  = sy-subrc.

* Get Document Item
  CLEAR gt_bseg.
  SELECT bukrs gjahr belnr buzei sgtxt wrbtr
         mwart saknr mwskz zuonr
    INTO CORRESPONDING FIELDS OF TABLE gt_bseg
    FROM vbsegs
    WHERE bukrs EQ p_bukrs AND
          belnr EQ p_belnr AND
          gjahr EQ p_gjahr
*{   REPLACE        P01K910536                                        2
*\    %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
  "End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

  SELECT bukrs gjahr belnr buzei kunnr mwskz zuonr
    INTO CORRESPONDING FIELDS OF TABLE lt_bseg
    FROM vbsegd
    WHERE bukrs EQ p_bukrs AND
          belnr EQ p_belnr AND
          gjahr EQ p_gjahr
*{   REPLACE        P01K910536                                        3
*\    %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
  "End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

  SORT gt_bseg BY bukrs belnr gjahr.
  SORT lt_bseg BY bukrs belnr gjahr.
  LOOP AT gt_bseg.
    gt_bseg-koart = 'S'.
    gt_bseg-hkont = gt_bseg-saknr.
    CASE gt_bseg-mwskz.
      WHEN 'K2' OR 'K5' OR 'K8'.
        ADD gt_bseg-wrbtr TO ld_wrbk2.
      WHEN 'K3' OR 'K7' OR 'K9'.
        ADD gt_bseg-wrbtr TO ld_wrbk3.
      WHEN OTHERS.
        ADD gt_bseg-wrbtr TO ld_wrbtr.
    ENDCASE.
    READ TABLE lt_bseg WITH KEY bukrs = gt_bseg-bukrs
                                belnr = gt_bseg-belnr
                                gjahr = gt_bseg-gjahr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_bseg-kunnr = lt_bseg-kunnr.
      gt_bseg-zuonr = lt_bseg-zuonr.
    ENDIF.
    MODIFY gt_bseg TRANSPORTING koart hkont kunnr zuonr.
  ENDLOOP.

  IF gt_bseg[] IS NOT INITIAL.
    SELECT kalsm mwskz text1
      FROM t007s
      INTO TABLE lt_t007s
      FOR ALL ENTRIES IN gt_bseg
      WHERE spras EQ sy-langu AND
            kalsm EQ 'TAXID'  AND
            mwskz EQ gt_bseg-mwskz.
  ENDIF.

  IF lt_t007s[] IS NOT INITIAL.
    LOOP AT lt_t007s.
      gt_bseg-mwskz = lt_t007s-mwskz.
      gt_bseg-buzei = gt_bseg-buzei + 1.
      gt_bseg-hkont = '0315300210'.
      CASE lt_t007s-mwskz.
        WHEN 'A0'.
        WHEN 'K2' OR 'K5' OR 'K8'.
          gt_bseg-wrbtr = ld_wrbk2.
          APPEND gt_bseg.
        WHEN 'K3' OR 'K7' OR 'K9'.
          gt_bseg-wrbtr = ld_wrbk3.
          APPEND gt_bseg.
        WHEN OTHERS.
          gt_bseg-wrbtr = ld_wrbtr.
          APPEND gt_bseg.
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_LEADING_ZERO
*&---------------------------------------------------------------------*
FORM f_delete_leading_zero  USING    fu_nrlevel
                            CHANGING fc_number.
  DATA:
    ld_length  TYPE i,
    ld_counter TYPE i,
    ld_nomor   TYPE zdgstfi_skcdl_header-nomor.

  ld_length = strlen( fu_nrlevel ).
  ld_length = ld_length - 7.
  ld_counter = 0.
  WHILE ld_counter < ld_length AND fu_nrlevel+ld_counter(1) = '0'.
    ld_counter = ld_counter + 1.
  ENDWHILE.

  ld_length = ld_length - ld_counter + 7.
  ld_nomor = fu_nrlevel+ld_counter(ld_length) + 1.
  fc_number = ld_nomor.
ENDFORM.                    " F_DELETE_LEADING_ZERO

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER_PTT
*&---------------------------------------------------------------------*
FORM f_get_next_number_ptt .
*  DATA: lv_name2 LIKE t880-name2.
  DATA: ls_zfgsnomor2 LIKE zfgsnomor2.

  LOOP AT gt_bseg.
    IF gt_bseg-vbund IS NOT INITIAL.
      gv_vbund = gt_bseg-vbund.
      EXIT.
    ENDIF.
  ENDLOOP.

*  SELECT SINGLE name2 INTO lv_name2
*    FROM t880 WHERE rcomp = gt_bseg-vbund.
*
*  SELECT SINGLE nomor INTO gv_nomor
*    FROM zfgsnomor WHERE gsber = gv_gsber           "'0200'
*                     AND spmon = gs_bkpf-budat(6)
*                     AND zform = 'DN'.

*  ADD 1 TO gv_nomor.
*  CONCATENATE lv_name2(3) '/' gs_bkpf-budat+4(2) gs_bkpf-budat+2(2)
*    INTO gs_header-xblnr.
*  CONCATENATE gs_header-xblnr gv_nomor+1(3)
*    INTO gs_header-xblnr SEPARATED BY '/'.

  SELECT SINGLE * INTO ls_zfgsnomor2
    FROM zfgsnomor2 WHERE gsber = gv_gsber
                      AND vbund = gv_vbund
                      AND spmon = gs_bkpf-budat(6).
  IF sy-subrc = 0.
    gv_nomor = ls_zfgsnomor2-nomor2 + 1.
    CONCATENATE ls_zfgsnomor2-name2 '/' gs_bkpf-budat+4(2) gs_bkpf-budat+2(2)
      INTO gs_header-xblnr.
    CONCATENATE gs_header-xblnr gv_nomor+1(3)
      INTO gs_header-xblnr SEPARATED BY '/'.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER_PTT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_GSNOMOR
*&---------------------------------------------------------------------*
FORM update_gsnomor .
*  UPDATE zfgsnomor SET nomor = gv_nomor
*    WHERE gsber = gv_gsber                          "'0200'
*      AND spmon = gs_bkpf-budat(6)
*      AND zform = 'DN'.
  CASE p_bukrs.
    WHEN  '8020' OR '8070'.
      UPDATE zfgsnomor2 SET nomor2 = gv_nomor
        WHERE gsber = gv_gsber                              "'0200'
          AND vbund = gv_vbund
          AND spmon = gs_bkpf-budat(6).

    WHEN OTHERS.
      UPDATE zfgsnomor SET nomor = gv_nomor
        WHERE gsber = gv_gsber                              "'0200'
          AND spmon = gs_bkpf-budat(6)
          AND zform = 'DN'.
  ENDCASE.
ENDFORM.                    " UPDATE_GSNOMOR

*&---------------------------------------------------------------------*
*&      Form  F_ROUNDING
*&---------------------------------------------------------------------*
FORM f_rounding  USING    fu_wrbtr fu_value1 fu_value2 fu_sign fu_mwskz
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE p DECIMALS 4.

  IF fu_mwskz IS NOT INITIAL.
    lv_wrbtr = fu_wrbtr * ( fu_value1 / fu_value2 ).
  ELSE.
    lv_wrbtr = fu_wrbtr * ( fu_value1 / fu_value2 ).
  ENDIF.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = lv_wrbtr
      sign          = fu_sign
    IMPORTING
      output        = fc_wrbtr
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUNDING

*&---------------------------------------------------------------------*
*&      Form  F_ROUNDING_TAX
*&---------------------------------------------------------------------*
FORM f_rounding_tax  USING    fu_wrbtr fu_value1 fu_value2 fu_sign fu_mwskz
                     CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE p DECIMALS 4.

  IF fu_mwskz IS NOT INITIAL.
    lv_wrbtr = fu_wrbtr * ( fu_value1 / fu_value2 ).
  ELSE.
    lv_wrbtr = fu_wrbtr * ( fu_value1 / fu_value2 ).
  ENDIF.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = lv_wrbtr
      sign          = fu_sign
    IMPORTING
      output        = fc_wrbtr
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUNDING_TAX
