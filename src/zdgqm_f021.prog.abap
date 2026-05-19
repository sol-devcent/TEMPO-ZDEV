*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : FQM-21
*& Functional Designer   : Yustin Kusnidar
*& ABAP Developer        : Didik Imawan
*& Initial Creation Date : 11.06.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& Setelah selesai process Inspection dengan dilakukannya Usage Decision.
*& Saat Usage decision, diputuskan hasil Inspectionnya Accept atau Reject.
*& Jika Accept akan dilakukan posting stock dari QI stock ke UU,
*& dan diikuti print QC Label # Pass dan ditempelkan di fisik barang.
*& Jika UD Reject, akan dilakukan posting dari QI ke Block Stock,
*& diikuti Print QC Label # Reject dan ditempelkan di fisik barang.
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
REPORT  zdgqm_f021 NO STANDARD PAGE HEADING.

* Please add comments before any group of codes and data declarations,
* and subroutine calls.

*-----------------------------------------------------------------------------*
* T A B L E S
*-----------------------------------------------------------------------------*
* Tables are usually used to define work-area for select-options in selection
* screen, or for NAST header
*-----------------------------------------------------------------------------*
TABLES: qals.

*-----------------------------------------------------------------------------*
* T Y P E S
*-----------------------------------------------------------------------------*
* Declare all Type Pools, Standard Types, and Table Types here.
* Naming convention: ty_xxx (types)
*                    ty_xxx_tab (table types)
*-----------------------------------------------------------------------------*



*-----------------------------------------------------------------------------*
* I N T E R N A L   T A B L E S   &   W O R K I N G - A R E A S
*-----------------------------------------------------------------------------*
* Naming convention: gt_xxx (global internal tables)
*                    wa_xxx (global working areas)
*-----------------------------------------------------------------------------*
DATA:  BEGIN OF t_qals OCCURS 0,
         prueflos    TYPE qals-prueflos,
         werk        TYPE qals-werk,
         art         TYPE qals-art,
         objnr       TYPE qals-objnr,
         matnr       TYPE qals-matnr,
         charg       TYPE qals-charg,
         lmenge01    TYPE qals-lmenge01,
         lmenge04    TYPE qals-lmenge04,
         offen_lzmk  TYPE qals-offen_lzmk,
         einhprobe   TYPE qals-einhprobe,
         mjahr       TYPE qals-mjahr,
         mblnr       TYPE qals-mblnr,
         budat       TYPE qals-budat,
       END OF t_qals,
       BEGIN OF t_t001w OCCURS 0,
         werks       TYPE t001w-werks,
         name1       TYPE t001w-name1,
       END OF t_t001w,
       BEGIN OF t_mara OCCURS 0,
         matnr       TYPE mara-matnr,
         mtart       TYPE mara-mtart,
         maktx       TYPE makt-maktx,
       END OF t_mara,
       BEGIN OF t_mch1 OCCURS 0,
         matnr       TYPE mch1-matnr,
         charg       TYPE mch1-charg,
         qndat       TYPE mch1-qndat,
         vfdat       TYPE mch1-vfdat,
         licha       TYPE mch1-licha,
       END OF t_mch1,
       BEGIN OF t_qave OCCURS 0,
         prueflos    TYPE qave-prueflos,
         kzart       TYPE qave-kzart,
         zaehler     TYPE qave-zaehler,
         vcode       TYPE qave-vcode,
         vdatum      TYPE qave-vdatum,
         vaedatum    TYPE qave-vaedatum,
       END OF t_qave.
DATA: BEGIN OF t_qclabel OCCURS 0.
        INCLUDE STRUCTURE zdgstqm_qc_label.
DATA: END OF t_qclabel.

DATA: gt_mkpf           TYPE TABLE OF mkpf WITH HEADER LINE.
DATA: gv_smartform_name TYPE tdsfname.
DATA: gv_limit          TYPE int3.

*-----------------------------------------------------------------------------*
* G L O B A L   V A R I A B L E S
*-----------------------------------------------------------------------------*
* Naming convention: gv_xxxx (variables)
*                    gs_xxxx (structures)
*-----------------------------------------------------------------------------*



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



*-----------------------------------------------------------------------------*
* C O N S T A N T S
*-----------------------------------------------------------------------------*
* Naming convention: c_xxxxx
*-----------------------------------------------------------------------------*

CONSTANTS: c_smartform_name  TYPE tdsfname      VALUE 'ZDGQM_004_8F',
           c_art             TYPE qpart         VALUE '04E'.


*-----------------------------------------------------------------------------*
* S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_pruef FOR qals-prueflos NO INTERVALS OBLIGATORY.  "Inspection Lot
PARAMETERS: pa_lblno     TYPE numc2 OBLIGATORY DEFAULT '1'.

SELECTION-SCREEN SKIP.
PARAMETERS: p_rad1  RADIOBUTTON GROUP grp1 USER-COMMAND us1 MODIF ID hid,
            p_rad2  RADIOBUTTON GROUP grp1 MODIF ID hid,
            p_rad3  RADIOBUTTON GROUP grp1 MODIF ID hid,
            p_rad4  RADIOBUTTON GROUP grp1 MODIF ID hid.
SELECTION-SCREEN END OF BLOCK b1.


*-----------------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
* Define selection screen validation
*-----------------------------------------------------------------------------*
AT SELECTION-SCREEN.



AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'HID'..
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.



*-----------------------------------------------------------------------------*
* S T A R T - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* Start-of-Selection should only be a list of subroutines (for retreiving and
* calculating data) and high level IF conditions, so that we can get the big
* picture of the program and we can drill-down specific process in the
* subroutines.
*-----------------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_proses_data.


*-----------------------------------------------------------------------------*
* E N D - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* End-of-selection will be a list (and high level IF condition) for generating
* and displaying report and it's features (after data collection).
*-----------------------------------------------------------------------------*
  IF t_qclabel[] IS NOT INITIAL.
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
  ELSE.

*   No record found
    MESSAGE s000(zab) WITH 'No UD recorded for Inspection Lot' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ENDIF.

  IF t_mara-mtart = 'ZRM'.
    gv_smartform_name = 'ZDGQM_004_6F_RM'.
  ENDIF.
*
* Print Smartforms
  PERFORM f_print_smartforms USING gv_smartform_name.   "c_smartform_name.
  REFRESH: t_qclabel.
  CLEAR: t_qclabel.


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
    l_funcname          TYPE tdsfname,
    l_total_pages       TYPE tdsffpage,
    lwa_control_option  TYPE ssfctrlop,
    lwa_output_option   TYPE ssfcompop,
    lwa_doc_info        TYPE ssfcrespd,
    lwa_output_info     TYPE ssfcrescl.

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

  LOOP AT t_qclabel.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    CALL FUNCTION l_funcname
      EXPORTING
        user_settings      = 'X'
        control_parameters = lwa_control_option
        t_qclabel          = t_qclabel
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    "f_print_smartforms

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_t001w  LIKE t_qals OCCURS 0 WITH HEADER LINE,
        lt_mara   LIKE t_qals OCCURS 0 WITH HEADER LINE,
        lt_mch1   LIKE t_qals OCCURS 0 WITH HEADER LINE.

  SELECT prueflos werk art objnr matnr charg lmenge01 lmenge04 offen_lzmk
    einhprobe mjahr mblnr budat
    FROM qals
    INTO TABLE t_qals
    WHERE prueflos IN so_pruef.
*      AND art = c_art.

  IF  t_qals[] IS NOT INITIAL.
    SELECT mblnr mjahr budat
      INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
      FROM mkpf FOR ALL ENTRIES IN t_qals
      WHERE mblnr = t_qals-mblnr
        AND mjahr = t_qals-mjahr.
  ENDIF.

  lt_t001w[]  = t_qals[].
  SORT lt_t001w BY werk.
  DELETE ADJACENT DUPLICATES FROM lt_t001w COMPARING werk.
  IF lt_t001w[] IS NOT INITIAL.
    SELECT werks name1
      FROM t001w
      INTO TABLE t_t001w
      FOR ALL ENTRIES IN lt_t001w
      WHERE werks EQ lt_t001w-werk
*{   REPLACE        P01K910570                                        1
*\      %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
  "%_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'
      . "#EC CI_HINTS
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
  ENDIF.

  lt_mara[]  = t_qals[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  IF lt_mara[] IS NOT INITIAL.
    SELECT a~matnr mtart maktx
      FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
      INTO TABLE t_mara
      FOR ALL ENTRIES IN lt_mara
      WHERE a~matnr EQ lt_mara-matnr
*{   REPLACE        P01K910570                                        2
*\      %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
  "%_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'
      . "#EC CI_HINTS
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
  ENDIF.

  lt_mch1[] = t_qals[].
  SORT lt_mch1 BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_mch1 COMPARING matnr charg.
  IF lt_mch1[] IS NOT INITIAL.
    SELECT matnr charg qndat vfdat licha
      FROM mch1
      INTO TABLE t_mch1
      FOR ALL ENTRIES IN lt_mch1
      WHERE matnr EQ lt_mch1-matnr  AND
            charg EQ lt_mch1-charg
*{   REPLACE        P01K910570                                        3
*\      %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
  "%_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'
      . "#EC CI_HINTS
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
  ENDIF.

  SELECT prueflos kzart zaehler vcode vdatum vaedatum
    FROM qave
    INTO TABLE t_qave
    WHERE prueflos IN so_pruef
*{   REPLACE        P01K910570                                        4
*\    %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
  "%_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'
    . "#EC CI_HINTS
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: ld_answer(2),
        ld_uddate   TYPE sy-datum,
        ld_grdate   TYPE sy-datum,
        ld_flag     TYPE int4,
        ld_index    TYPE sy-index,
        ls_status   TYPE jstat.

  DATA : mtcom  TYPE mtcom.
  DATA:  BEGIN OF g_mchar OCCURS 0.
          INCLUDE STRUCTURE mchar.
  DATA   END OF g_mchar.
  DATA : status   TYPE STANDARD TABLE OF jstat INITIAL SIZE 0.

  LOOP AT t_qals.
    AUTHORITY-CHECK OBJECT 'Q_INSPTYPE'
    ID 'WERKS' FIELD t_qals-werk.
    IF sy-subrc NE 0.
      MESSAGE e000(zab) WITH 'You are not authorized with Plant' t_qals-werk.
      LEAVE PROGRAM.
    ENDIF.

    mtcom-kenng = 'MCHAR'.
    mtcom-matnr = t_qals-matnr.
    mtcom-werks = t_qals-werk.
    mtcom-charg = t_qals-charg.

    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel           = mtcom
      IMPORTING
        matdaten             = g_mchar
      TABLES
        seqmat01             = g_mchar
      EXCEPTIONS
        account_not_found    = 1
        batch_not_found      = 2
        forecast_not_found   = 3
        lock_on_account      = 4
        lock_on_material     = 5
        lock_on_plant        = 6
        lock_on_sales        = 7
        lock_on_sloc         = 8
        lock_on_batch        = 9
        lock_system_error    = 10
        material_not_found   = 11
        plant_not_found      = 12
        sales_not_found      = 13
        sloc_not_found       = 14
        slocnumber_not_found = 15
        sloctype_not_found   = 16
        text_not_found       = 17
        unit_not_found       = 18
        invalid_mch1_matnr   = 19
        invalid_mtcom        = 20
        sa_material          = 21
        wv_material          = 22
        waart_error          = 23
        t134m_not_found      = 24
        OTHERS               = 25.

    READ TABLE t_t001w WITH KEY werks = t_qals-werk.
    IF sy-subrc EQ 0.
      t_qclabel-name1 = t_t001w-name1.
    ENDIF.
    READ TABLE t_mara WITH KEY matnr = t_qals-matnr.
    IF sy-subrc EQ 0.
      t_qclabel-maktx = t_mara-maktx.
    ENDIF.
    t_qclabel-matnr    = t_qals-matnr.
    t_qclabel-charg    = t_qals-charg.
    t_qclabel-prueflos = t_qals-prueflos.
    READ TABLE t_qave WITH KEY prueflos = t_qals-prueflos.
    IF sy-subrc EQ 0.
      CASE t_qave-vcode.
        WHEN '010'.
          t_qclabel-passreject  = 'Total Passed Qty'.
          WRITE t_qals-lmenge01 TO t_qclabel-total UNIT t_qals-einhprobe.
          t_qclabel-udcode      = 'ACCEPT'.
          t_qclabel-header      = 'PASSED'.
        WHEN '020'.
          t_qclabel-passreject  = 'Total Reject Qty'.
          WRITE t_qals-lmenge04 TO t_qclabel-total UNIT t_qals-einhprobe.
          t_qclabel-udcode      = 'REJECT'.
          t_qclabel-header      = 'REJECT'.
        WHEN '030'.
          t_qclabel-passreject  = 'Total Passed Qty'.
          WRITE t_qals-lmenge01 TO t_qclabel-total UNIT t_qals-einhprobe.
          t_qclabel-udcode      = 'ACCEPT WITH NOTES'.
          t_qclabel-header      = 'PASSED'.
        WHEN '040'.
          t_qclabel-udcode      = 'ACCEPT/REJECT PARTIAL'.
          PERFORM f_popup_message USING t_qals-prueflos
                                  CHANGING ld_answer.
          CASE ld_answer.
            WHEN '1'.
              t_qclabel-passreject  = 'Total Passed Qty'.
              WRITE t_qals-lmenge01 TO t_qclabel-total UNIT t_qals-einhprobe.
              t_qclabel-header      = 'PASSED'.
            WHEN '2'.
              t_qclabel-passreject  = 'Total Reject Qty'.
              WRITE t_qals-lmenge04 TO t_qclabel-total UNIT t_qals-einhprobe.
              t_qclabel-header      = 'REJECT'.
          ENDCASE.
      ENDCASE.
      SHIFT t_qclabel-total LEFT DELETING LEADING space.

      IF g_mchar-zustd IS NOT INITIAL.
        t_qclabel-header = 'HOLD'.
      ELSE.
        CALL FUNCTION 'STATUS_READ'
          EXPORTING
            objnr            = t_qals-objnr
            only_active      = 'X'
          TABLES
            status           = status
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.

        READ TABLE status INTO ls_status WITH KEY stat = 'I0204'.
        IF sy-subrc = 0.
          t_qclabel-header = 'HOLD'.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = t_qals-einhprobe
          language       = sy-langu
        IMPORTING
          output         = t_qals-einhprobe
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      CONCATENATE t_qclabel-total t_qals-einhprobe INTO t_qclabel-total
      SEPARATED BY space.

      "Start SOH Adjustment 2024/08/18
      IF t_qave-vaedatum IS INITIAL OR
         t_qave-vaedatum LT t_qave-vdatum.
        t_qave-vaedatum = t_qave-vdatum.
      ENDIF.
      "End SOH Adjustment 2024/08/18

      IF t_qals-offen_lzmk IS INITIAL.
        ld_uddate = t_qave-vaedatum.
      ELSE.
        ld_uddate = t_qave-vaedatum + 2.
      ENDIF.
      WRITE ld_uddate TO t_qclabel-uddate DD/MM/YYYY.

      READ TABLE gt_mkpf WITH KEY mblnr = t_qals-mblnr
                                  mjahr = t_qals-mjahr.
      WRITE gt_mkpf-budat TO t_qclabel-grdate DD/MM/YYYY.

      READ TABLE t_mch1 WITH KEY matnr  = t_qals-matnr
                                 charg  = t_qals-charg.
      IF sy-subrc EQ 0.
        t_qclabel-licha = t_mch1-licha.
        IF t_mch1-qndat IS INITIAL.
          CLEAR: t_qclabel-retestdt.
        ELSE.
          WRITE t_mch1-qndat TO t_qclabel-retestdt DD/MM/YYYY.
        ENDIF.
        IF t_mch1-vfdat IS INITIAL.
          CLEAR: t_qclabel-sledate.
        ELSE.
          WRITE t_mch1-vfdat TO t_qclabel-sledate DD/MM/YYYY.
        ENDIF.
      ENDIF.

      PERFORM f_modify_total USING t_qals-art t_mara-mtart
                             CHANGING t_qclabel-passreject t_qclabel-total.

      DO pa_lblno TIMES.
        ADD 1 TO ld_flag.
        CASE ld_flag.
          WHEN 1.
            ADD 1 TO ld_index.
            t_qclabel-1header = t_qclabel-header.
            APPEND t_qclabel.
          WHEN 2.
            t_qclabel-2header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 3.
            t_qclabel-3header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 4.
            t_qclabel-4header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 5.
            t_qclabel-5header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 6.
            t_qclabel-6header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 7.
            t_qclabel-7header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
          WHEN 8.
            t_qclabel-8header = t_qclabel-header.
            MODIFY t_qclabel INDEX ld_index.
        ENDCASE.

        IF ld_flag = gv_limit.
          CLEAR : ld_flag,
                  t_qclabel-1header, t_qclabel-2header,
                  t_qclabel-3header, t_qclabel-4header,
                  t_qclabel-5header, t_qclabel-6header,
                  t_qclabel-7header, t_qclabel-8header.
        ENDIF.
      ENDDO.

    ENDIF.
    CLEAR: t_qclabel, ld_flag.
  ENDLOOP.
ENDFORM.                    " F_PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_popup_message USING fu_prueflos
                     CHANGING answer.
  DATA: ld_text(50).
  CONCATENATE 'Inspection Lot No.' fu_prueflos INTO ld_text
  SEPARATED BY space.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'ACCEPT/REJECT PARTIAL'
      text_question         = ld_text
      text_button_1         = 'Accept'
      text_button_2         = 'Reject'
      display_cancel_button = ''
    IMPORTING
      answer                = answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
ENDFORM.                    " F_POPUP_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TOTAL
*&---------------------------------------------------------------------*
FORM f_modify_total  USING    fu_art fu_mtart
                     CHANGING fc_passreject fc_total.
  IF fu_art EQ '04E' AND
    fu_mtart EQ 'ZCGB'.
    CLEAR: fc_passreject, fc_total.
  ENDIF.
ENDFORM.                    " F_MODIFY_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  CLEAR: p_rad1,p_rad2,p_rad3,p_rad4.
  p_rad2 = 'X'.

  CASE 'X'.
    WHEN p_rad1.
      gv_smartform_name = 'ZDGQM_004_V31'.
      gv_limit = 4.
    WHEN p_rad2.
      gv_smartform_name = 'ZDGQM_004_6F'.
      gv_limit = 6.
    WHEN p_rad3.
      gv_smartform_name = 'ZDGQM_004_8F'.
      gv_limit = 8.
    WHEN p_rad4.
      gv_smartform_name = 'ZDGQM_004_8F_POT'.   "'ZDGQM_004_8F'.
      gv_limit = 8.
  ENDCASE.
ENDFORM.                    " F_INIT_DATA
