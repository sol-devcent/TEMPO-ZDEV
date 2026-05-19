*&----------------------------------------------------------------------------*
*& D R A G O N   G L O R Y   P R O J E C T
*&----------------------------------------------------------------------------*
*& RICEF ID              : FFI-26
*& Functional Designer   : Mourme Taruna Halim
*& ABAP Developer        : Didik Imawan
*& Initial Creation Date : 29.06.2012
*&
*& Overview: (paste business requirement from FuncSpec here)
*& Automatic payment voucher yang dibuat dalam functional specification ini adalah
*& form untuk memodifikasi existing payment voucher yang dihasilkan dari t-code ZF21
*& yang sudah ada sekarang. Isinya berupa permintaan pembayaran ke Treasury atas
*& Account Payable yang sudah jatuh tempo. Form yang ada sekarang perlu disesuaikan
*& dengan kebutuhan RS & TLOG.
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
REPORT  zdgfi_f026.

* Please add comments before any group of codes and data declarations,
* and subroutine calls.

*-----------------------------------------------------------------------------*
* T A B L E S
*-----------------------------------------------------------------------------*
* Tables are usually used to define work-area for select-options in selection
* screen, or for NAST header
*-----------------------------------------------------------------------------*
TABLES: reguh, regup.

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
DATA: BEGIN OF tab_laufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
      DATA: END OF tab_laufk.

DATA: BEGIN OF t_reguh OCCURS 0,
        laufd TYPE reguh-laufd,
        laufi TYPE reguh-laufi,
        xvorl TYPE reguh-xvorl,
        zbukr TYPE reguh-zbukr,
        lifnr TYPE reguh-lifnr,
        kunnr TYPE reguh-kunnr,
        empfg TYPE reguh-empfg,
        vblnr TYPE reguh-vblnr,
        name1 TYPE reguh-name1,
        srtgb TYPE reguh-srtgb,
        pyord TYPE reguh-pyord,
        stras TYPE reguh-stras,
        ort01 TYPE reguh-ort01,
      END OF t_reguh,

      BEGIN OF t_regup OCCURS 0,
        laufd TYPE regup-laufd,
        laufi TYPE regup-laufi,
        xvorl TYPE regup-xvorl,
        zbukr TYPE regup-zbukr,
        lifnr TYPE regup-lifnr,
        kunnr TYPE regup-kunnr,
        empfg TYPE regup-empfg,
        vblnr TYPE regup-vblnr,
        bukrs TYPE regup-bukrs,
        belnr TYPE regup-belnr,
        gjahr TYPE regup-gjahr,
        buzei TYPE regup-buzei,
        waers TYPE regup-waers,
        xblnr TYPE regup-xblnr,
        shkzg TYPE regup-shkzg,
        dmbtr TYPE regup-dmbtr,
        wrbtr TYPE regup-wrbtr,
        gsber TYPE regup-gsber,
      END OF t_regup,

      BEGIN OF t_bsik OCCURS 0,
        bukrs TYPE bsik-bukrs,
        lifnr TYPE bsik-lifnr,
        gjahr TYPE bsik-gjahr,
        belnr TYPE bsik-belnr,
        xblnr TYPE bsik-xblnr,
        monat TYPE bsik-monat,
        zfbdt TYPE bsik-zfbdt,
        zbd1t TYPE bsik-zbd1t,
      END OF t_bsik,

      BEGIN OF t_t001 OCCURS 0,
        bukrs TYPE t001-bukrs,
        butxt TYPE t001-butxt,
        name1 TYPE adrc-name1,
      END OF t_t001,

      BEGIN OF t_lfa1 OCCURS 0,
        lifnr TYPE lfa1-lifnr,
        name1 TYPE lfa1-name1,
        stceg TYPE lfa1-stceg,
      END OF t_lfa1.

*DATA : gt_acc TYPE zfacc_receipt OCCURS 0 WITH HEADER LINE,
*       wa_acc LIKE zfacc_receipt.

DATA: BEGIN OF t_header OCCURS 0.
        INCLUDE STRUCTURE zdgstfi_apv_header.
      DATA: END OF t_header.

DATA: BEGIN OF t_vdata OCCURS 0.
        INCLUDE STRUCTURE zdgstfi_apv_detail.
      DATA: END OF t_vdata.

DATA: BEGIN OF t_detail OCCURS 0.
        INCLUDE STRUCTURE zdgstfi_apv_detail.
      DATA: END OF t_detail.

DATA: BEGIN OF t_bsis OCCURS 0,
        bukrs TYPE bukrs,
        hkont TYPE hkont,
        gjahr TYPE gjahr,
        belnr TYPE belnr_d,
        shkzg TYPE shkzg,
        wrbtr TYPE wrbtr,
      END OF t_bsis.

*DATA: t_save     LIKE zftrn_receipt OCCURS 0 WITH HEADER LINE,
*      t_trn      LIKE zftrn_receipt OCCURS 0 WITH HEADER LINE,
*      t_pyrd     LIKE zftrn_receipt OCCURS 0 WITH HEADER LINE,
*      wa_nriv    LIKE nriv.

*-----------------------------------------------------------------------------*
* G L O B A L   V A R I A B L E S
*-----------------------------------------------------------------------------*
* Naming convention: gv_xxxx (variables)
*                    gs_xxxx (structures)
*-----------------------------------------------------------------------------*
DATA: gv_rec     TYPE i,
      wa_header  LIKE t_header,
      gv_nomor   TYPE num4,
      gv_type(2).

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

DATA: c_smartform_name  TYPE tdsfname      VALUE 'ZDGFI_010'.

*-----------------------------------------------------------------------------*
* S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS : pa_laufd LIKE reguh-laufd OBLIGATORY,
             pa_laufi LIKE reguh-laufi OBLIGATORY.
SELECT-OPTIONS so_lifnr FOR reguh-lifnr.
SELECTION-SCREEN SKIP 1.
PARAMETERS : pa_prev  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK c.
PARAMETERS : pa_paydt TYPE dats.
PARAMETERS : pa_name(20) ,
             pa_cekno(20),
             pa_acno(20).
SELECTION-SCREEN END OF BLOCK c.

INITIALIZATION.
  REFRESH tab_laufk.
  tab_laufk-laufk = 'W'.
  tab_laufk-sign  = 'E'.
  APPEND tab_laufk.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_laufd.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'PA_LAUFI'
    IMPORTING
      laufd = pa_laufd
      laufi = pa_laufi
    TABLES
      laufk = tab_laufk.

*-----------------------------------------------------------------------------*
* A T   S E L E C T I O N - S C R E E N
*-----------------------------------------------------------------------------*
* Define selection screen validation
*-----------------------------------------------------------------------------*
AT SELECTION-SCREEN.



AT SELECTION-SCREEN OUTPUT.




*-----------------------------------------------------------------------------*
* S T A R T - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* Start-of-Selection should only be a list of subroutines (for retreiving and
* calculating data) and high level IF conditions, so that we can get the big
* picture of the program and we can drill-down specific process in the
* subroutines.
*-----------------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_get_data.
  PERFORM f_process_data.



*-----------------------------------------------------------------------------*
* E N D - O F - S E L E C T I O N
*-----------------------------------------------------------------------------*
* End-of-selection will be a list (and high level IF condition) for generating
* and displaying report and it's features (after data collection).
*-----------------------------------------------------------------------------*
  IF NOT t_header[] IS INITIAL.

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
*
*   No record found
    MESSAGE s001(oiuh) DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ENDIF.

* Print Smartforms
  READ TABLE t_header INDEX 1.
  IF t_header-zbukr EQ '8050'.
    c_smartform_name  = 'ZDGFI_010'.
*    IF gv_type IS NOT INITIAL.
*      SELECT SINGLE *
*        FROM nriv
*        INTO wa_nriv
*        WHERE object      = 'ZFPPH23'
*          AND subobject   = t_header-zbukr
*          AND nrrangenr   = '01'
*          AND toyear      = t_header-gjahr.
*      IF sy-subrc <> 0.
*        MESSAGE s000(zab) WITH 'No Bukti belum dimaintain'
*                          DISPLAY LIKE 'E'.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*    ENDIF.
  ELSEIF t_header-zbukr EQ '8230'.
    c_smartform_name  = 'ZDGFI_010RS'.
  ELSEIF t_header-zbukr EQ '8020' OR
    t_header-zbukr EQ '8070'.
    c_smartform_name  = 'ZDGFI_010PTT'.
  ELSEIF t_header-zbukr EQ '8380'.
    c_smartform_name  = 'ZDGFI_010TDN'.
  ENDIF.

  PERFORM f_print_smartforms USING c_smartform_name.

*  SORT t_save BY bukrs pyord laufd laufi lifnr belnr gjahr
*                 buzei type hkont gsber.
*  SORT t_trn BY bukrs pyord laufd laufi lifnr belnr gjahr
*                 buzei type hkont gsber.

*  IF t_header-zbukr EQ '8050'.
*    IF sy-ucomm = 'PRNT'.
*      IF t_pyrd[] IS NOT INITIAL.
*        LOOP AT t_pyrd.
*          CLEAR gv_nomor.
*          PERFORM f_get_next_number USING t_pyrd-bukrs t_pyrd-gjahr
*                                    CHANGING gv_nomor.
*          LOOP AT t_save WHERE bukrs = t_pyrd-bukrs
*                           AND pyord = t_pyrd-pyord.
*            READ TABLE t_trn WITH KEY bukrs  = t_save-bukrs
*                                      pyord  = t_save-pyord
*                                      laufd  = t_save-laufd
*                                      laufi  = t_save-laufi
*                                      lifnr  = t_save-lifnr
*                                      belnr  = t_save-belnr
*                                      gjahr  = t_save-gjahr
*                                      buzei  = t_save-buzei
*                                      type  = t_save-type
*                                      hkont  = t_save-hkont
*                                      gsber  = t_save-gsber
*                             BINARY SEARCH
*                             TRANSPORTING NO FIELDS.
*            IF sy-subrc = 0.
*              CONTINUE.
*            ENDIF.
*            t_save-nobukti(4) = gv_nomor.
*            INSERT zftrn_receipt FROM t_save.
*          ENDLOOP.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*  ENDIF.

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
  DATA: ls_ztusfidt001 TYPE ztusfidt001.
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

*  SORT t_header BY zvoucher.
  LOOP AT t_header.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    CLEAR: t_detail, t_detail[], gv_rec.
    LOOP AT t_vdata WHERE laufd     EQ t_header-laufd
                      AND laufi     EQ t_header-laufi
                      AND lifnr     EQ t_header-lifnr
                      AND vblnr     EQ t_header-vblnr.
      t_detail  = t_vdata.
      APPEND t_detail.
      CLEAR: t_detail.
    ENDLOOP.

    PERFORM f_modify_detail USING t_header-zbukr.

    IF t_detail[] IS NOT INITIAL.
      IF pa_prev IS INITIAL.
        lwa_output_option-tdnoprev = 'X'.
      ELSE.
        lwa_output_option-tdnoprint = 'X'.
        MOVE-CORRESPONDING t_detail TO ls_ztusfidt001.
        SELECT SINGLE * INTO ls_ztusfidt001 FROM ztusfidt001
          WHERE bukrs = t_header-zbukr
           AND laufd = t_detail-laufd
           AND laufi = t_detail-laufi.
        IF sy-subrc EQ 0.
          ls_ztusfidt001-aedat = sy-datum.
          ls_ztusfidt001-aenam = sy-uname.
          ls_ztusfidt001-aezet = sy-uzeit.
        ELSE.
          ls_ztusfidt001-bukrs = t_header-zbukr.
          ls_ztusfidt001-gsber = t_header-SRTGB.
          ls_ztusfidt001-erdat = sy-datum.
          ls_ztusfidt001-ernam = sy-uname.
          ls_ztusfidt001-erzet = sy-uzeit.
        ENDIF.
        ls_ztusfidt001-pay_date = pa_paydt.
        ls_ztusfidt001-bank_name = pa_name.
        ls_ztusfidt001-bank_ac = pa_acno.
        ls_ztusfidt001-cek_number = pa_cekno.
        MODIFY ztusfidt001 FROM ls_ztusfidt001.
      ENDIF.

      CALL FUNCTION l_funcname
        EXPORTING
*         user_settings      = 'X'
          control_parameters = lwa_control_option
          output_options     = lwa_output_option
          t_header           = t_header
          gv_rec             = gv_rec
        TABLES
          t_detail           = t_detail
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
    ENDIF.

    lwa_control_option-no_open = 'X'.
    CLEAR: t_header-znew.
  ENDLOOP.
ENDFORM.                    "f_print_smartforms

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_t001 LIKE t_reguh OCCURS 0 WITH HEADER LINE,
        lt_lfa1 LIKE t_reguh OCCURS 0 WITH HEADER LINE.
*        lt_acc    LIKE t_reguh OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_bsis OCCURS 0,
           bukrs TYPE bukrs,
           gsber TYPE gsber,
           gjahr TYPE gjahr,
           belnr TYPE belnr_d,
           hkont TYPE hkont,
         END OF lt_bsis.

  SELECT laufd laufi xvorl zbukr lifnr kunnr empfg vblnr name1 srtgb
    pyord stras ort01
    INTO TABLE t_reguh
    FROM reguh
    WHERE laufd EQ pa_laufd AND
          laufi EQ pa_laufi AND
          lifnr IN so_lifnr AND
          xvorl NE 'X' .

  lt_t001[] = t_reguh[].
  SORT lt_t001 BY zbukr.
  DELETE ADJACENT DUPLICATES FROM lt_t001 COMPARING zbukr.
  IF lt_t001[] IS NOT INITIAL.
    SELECT bukrs butxt name1
      FROM t001 JOIN adrc ON t001~adrnr = adrc~addrnumber
      INTO TABLE t_t001
      FOR ALL ENTRIES IN lt_t001
      WHERE bukrs EQ lt_t001-zbukr.
  ENDIF.

  lt_lfa1[] = t_reguh[].
  SORT lt_lfa1 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.
  IF lt_lfa1[] IS NOT INITIAL.
    SELECT lifnr name1 stceg
      FROM lfa1
      INTO TABLE t_lfa1
      FOR ALL ENTRIES IN lt_lfa1
      WHERE lifnr EQ lt_lfa1-lifnr.
  ENDIF.

  IF t_reguh[] IS NOT INITIAL.
    SELECT laufd laufi xvorl zbukr lifnr kunnr empfg vblnr bukrs belnr
           gjahr buzei waers xblnr shkzg dmbtr wrbtr gsber
      FROM regup
      INTO TABLE t_regup
      FOR ALL ENTRIES IN t_reguh
      WHERE laufd EQ t_reguh-laufd AND
            laufi EQ t_reguh-laufi AND
            lifnr EQ t_reguh-lifnr AND
            xvorl NE 'X'.
    IF t_regup[] IS NOT INITIAL.
      SELECT bukrs lifnr gjahr belnr xblnr monat zfbdt zbd1t
        FROM bsik
        INTO TABLE t_bsik
        FOR ALL ENTRIES IN t_regup
        WHERE belnr EQ t_regup-belnr AND
              bukrs EQ t_regup-zbukr AND
              gjahr EQ t_regup-gjahr AND
              lifnr EQ t_regup-lifnr.

      SELECT bukrs lifnr gjahr belnr xblnr monat zfbdt zbd1t
        FROM bsak
        APPENDING TABLE t_bsik
        FOR ALL ENTRIES IN t_regup
        WHERE belnr EQ t_regup-belnr AND
              bukrs EQ t_regup-zbukr AND
              gjahr EQ t_regup-gjahr AND
              lifnr EQ t_regup-lifnr.
    ENDIF.
  ENDIF.

*  lt_acc[] = t_reguh[].
*  SORT lt_acc BY zbukr srtgb.
*  DELETE ADJACENT DUPLICATES FROM lt_acc COMPARING zbukr srtgb.

*  IF lt_acc[] IS NOT INITIAL.
*    SELECT *
*      FROM zfacc_receipt
*      INTO TABLE gt_acc
*      FOR ALL ENTRIES IN lt_acc
*      WHERE bukrs   = lt_acc-zbukr
*        AND gsber   = lt_acc-srtgb.
*  ENDIF.

*  LOOP AT t_regup.
*    lt_bsis-bukrs = t_regup-bukrs.
*    lt_bsis-gsber = t_regup-gsber.
*    lt_bsis-gjahr = t_regup-gjahr.
*    lt_bsis-belnr = t_regup-belnr.
*    READ TABLE gt_acc WITH KEY bukrs = t_regup-bukrs
*                               gsber = t_regup-gsber.
*    IF sy-subrc = 0.
*      lt_bsis-hkont = gt_acc-hkont.
*    ENDIF.
*    APPEND lt_bsis.
*    CLEAR lt_bsis.
*  ENDLOOP.
*  SORT lt_bsis BY bukrs gsber gjahr belnr.
*  DELETE ADJACENT DUPLICATES FROM lt_bsis COMPARING bukrs gsber gjahr belnr.
*
*  IF lt_bsis[] IS NOT INITIAL.
*    SELECT bukrs hkont gjahr belnr shkzg wrbtr
*      FROM bsis
*      INTO TABLE t_bsis
*      FOR ALL ENTRIES IN lt_bsis
*      WHERE bukrs = lt_bsis-bukrs
*        AND hkont = lt_bsis-hkont
*        AND gjahr = lt_bsis-gjahr
*        AND belnr = lt_bsis-belnr.
*
*    SELECT bukrs hkont gjahr belnr shkzg wrbtr
*      FROM bsas
*      APPENDING TABLE t_bsis
*      FOR ALL ENTRIES IN lt_bsis
*      WHERE bukrs = lt_bsis-bukrs
*        AND hkont = lt_bsis-hkont
*        AND gjahr = lt_bsis-gjahr
*        AND belnr = lt_bsis-belnr.
*  ENDIF.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  DATA : lv_subrc   TYPE sy-subrc.

  LOOP AT t_reguh.
    t_header-laufd  = t_reguh-laufd.
    WRITE t_reguh-laufd TO t_header-laufdt DD/MM/YYYY.
    t_header-laufi  = t_reguh-laufi.
    t_header-xvorl  = t_reguh-xvorl.
    t_header-zbukr  = t_reguh-zbukr.
    READ TABLE t_t001 WITH KEY bukrs = t_reguh-zbukr.
    IF sy-subrc EQ 0.
      IF t_reguh-zbukr = '8380'.
        t_header-butxt  = t_t001-name1.
      ELSE.
        t_header-butxt  = t_t001-butxt.
      ENDIF.
      TRANSLATE t_header-butxt TO UPPER CASE.
    ENDIF.
    t_header-lifnr  = t_reguh-lifnr.
    READ TABLE t_lfa1 WITH KEY lifnr = t_reguh-lifnr.
    IF sy-subrc EQ 0.
      t_header-name1  = t_lfa1-name1.
    ENDIF.
    t_header-kunnr  = t_reguh-kunnr.
    t_header-empfg  = t_reguh-empfg.
    t_header-vblnr  = t_reguh-vblnr.
*    t_header-name1  = t_reguh-name1.
    t_header-srtgb  = t_reguh-srtgb.
    t_header-pyord  = t_reguh-pyord.
    t_header-name   = pa_name.
    t_header-cekno  = pa_cekno.
    t_header-acno   = pa_acno.
    WRITE sy-datum TO t_header-paydt DD/MM/YYYY.
    WRITE pa_paydt TO t_header-paydate DD/MM/YYYY.

*    CLEAR wa_acc.
*    READ TABLE gt_acc INTO wa_acc
*                      WITH KEY bukrs  = t_header-zbukr
*                               gsber  = t_header-srtgb.
*    IF sy-subrc = 0.
*      lv_subrc  = sy-subrc.
*    ENDIF.

* Get detail operation
    PERFORM f_get_detail USING t_reguh-laufd t_reguh-laufi
                               t_reguh-lifnr t_reguh-vblnr
*                               wa_acc
                         CHANGING t_header-waers t_header-total t_header-totalt
                                  t_header-say t_header-word t_header-gjahr
                                  t_header-monat.

*    IF lv_subrc = 0.
*      t_header-zvoucher = 'RV'.
*      APPEND t_header.
*    ENDIF.

*    t_header-zvoucher = 'PV'.
    APPEND t_header.
    CLEAR: t_header.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_detail  USING    fu_laufd fu_laufi fu_lifnr fu_vblnr
*                            fwa_acc STRUCTURE zfacc_receipt
                   CHANGING fc_waers fc_total fc_totalt fc_say fc_word
                            fc_gjahr fc_monat.

  DATA: in_words  LIKE spell OCCURS 0 WITH HEADER LINE,
        ld_nou(3),
        ld_langu  TYPE sy-langu.

  LOOP AT t_regup WHERE laufd EQ fu_laufd AND
                        laufi EQ fu_laufi AND
                        lifnr EQ fu_lifnr AND
                        vblnr EQ fu_vblnr.
    ADD 1 TO ld_nou.
    t_vdata-nou    = ld_nou.

    t_vdata-laufd  = t_regup-laufd.
    t_vdata-laufi  = t_regup-laufi.
    t_vdata-lifnr  = t_regup-lifnr.
    t_vdata-vblnr  = t_regup-vblnr.

    READ TABLE t_bsik WITH KEY belnr = t_regup-belnr
                               bukrs = t_regup-zbukr
                               gjahr = t_regup-gjahr
                               lifnr = t_regup-lifnr.
    IF sy-subrc EQ 0.
      t_vdata-xblnr  = t_bsik-xblnr.
      CASE t_regup-zbukr.
        WHEN '8380'.
          t_vdata-zfbdt  = t_bsik-zfbdt.
          t_vdata-duedt  = t_bsik-zfbdt + t_bsik-zbd1t.
        WHEN OTHERS.
          IF t_regup-zbukr = '8020' OR t_regup-zbukr = '8070'.
            t_vdata-zfbdt  = t_bsik-zfbdt.
          ELSE.
            t_vdata-zfbdt  = t_bsik-zfbdt + t_bsik-zbd1t.
          ENDIF.
      ENDCASE.

      fc_gjahr       = t_bsik-gjahr.
      fc_monat       = t_bsik-monat.
    ELSE.
      fc_gjahr       = t_regup-gjahr.
    ENDIF.
    t_vdata-belnr  = t_regup-belnr.
    t_vdata-belnr  = t_regup-belnr.
    t_vdata-waers  = t_regup-waers.
    IF t_regup-shkzg EQ 'S'.
      t_regup-dmbtr = t_regup-dmbtr * -1.
      t_regup-wrbtr = t_regup-wrbtr * -1.
    ENDIF.

    t_vdata-dmbtr  = t_regup-dmbtr.
    t_vdata-wrbtr  = t_regup-wrbtr.
    fc_waers  = t_vdata-waers.

    IF t_regup-waers EQ 'IDR'.
      WRITE t_regup-dmbtr TO t_vdata-amount CURRENCY t_regup-waers.
      ADD t_regup-dmbtr TO fc_total.
    ELSE.
      WRITE t_regup-wrbtr TO t_vdata-amount CURRENCY t_regup-waers.
      ADD t_regup-wrbtr TO fc_total.
    ENDIF.
    IF t_regup-shkzg EQ 'S'.
      REPLACE '-' WITH space INTO t_vdata-amount.
      SHIFT t_vdata-amount LEFT DELETING LEADING space.
      CONCATENATE '(' t_vdata-amount ')' INTO t_vdata-amount
      SEPARATED BY space.
    ENDIF.

*    t_vdata-zvoucher  = 'PV'.
    APPEND t_vdata.

*    READ TABLE t_bsis WITH KEY belnr = t_regup-belnr
*                               bukrs = t_regup-zbukr
*                               gjahr = t_regup-gjahr.
*    IF sy-subrc = 0.
*      t_vdata-zvoucher  = 'RV'.
*      APPEND t_vdata.
*      gv_type = 'RV'.
*      PERFORM f_prepare_save_document USING fwa_acc.
*    ENDIF.

    CLEAR: t_vdata.
  ENDLOOP.

*  IF t_save[] IS NOT INITIAL.
*    t_pyrd[] = t_save[].
*    SORT t_pyrd BY bukrs pyord.
*    DELETE ADJACENT DUPLICATES FROM t_pyrd COMPARING bukrs pyord.
*
*    SELECT bukrs pyord laufd laufi lifnr belnr gjahr
*      buzei type hkont gsber
*      FROM zftrn_receipt
*      INTO CORRESPONDING FIELDS OF TABLE t_trn
*      FOR ALL ENTRIES IN t_save
*      WHERE bukrs  = t_save-bukrs
*        AND pyord  = t_save-pyord
*        AND laufd  = t_save-laufd
*        AND laufi  = t_save-laufi
*        AND lifnr  = t_save-lifnr
*        AND belnr  = t_save-belnr
*        AND gjahr  = t_save-gjahr
*        AND buzei  = t_save-buzei
*        AND type  = t_save-type
*        AND hkont  = t_save-hkont
*        AND gsber  = t_save-gsber.
*  ENDIF.

  WRITE fc_total TO fc_totalt CURRENCY fc_waers.

  IF fc_waers EQ 'IDR'.
    ld_langu  = 'i'.
  ELSE.
    ld_langu  = sy-langu.
  ENDIF.
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount                = fc_total
      currency              = fc_waers
      language              = ld_langu
    IMPORTING
      in_words              = in_words
    EXCEPTIONS
      records_not_found     = 1
      records_not_requested = 2
      OTHERS                = 3.

  IF fc_waers EQ 'IDR'.
    fc_say  = 'TERBILANG'.
*    CONCATENATE fc_waers in_words-word INTO fc_word
*    SEPARATED BY space.
    CONCATENATE in_words-word 'RUPIAH' INTO fc_word
    SEPARATED BY space.
  ELSE.
    fc_say  = 'SAY'.
    IF in_words-decword IS INITIAL.
      CONCATENATE fc_waers in_words-word 'ONLY' INTO fc_word
      SEPARATED BY space.
    ELSE.
      CONCATENATE fc_waers in_words-word 'AND' in_words-decword 'CENTS ONLY'
      INTO fc_word SEPARATED BY space.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DETAIL
*&---------------------------------------------------------------------*
FORM f_modify_detail  USING    fu_zbukr.
  DATA: lv_mod   TYPE i,
        lv_count TYPE i,
        lv_calc  TYPE i,
        lv_space TYPE i,
        lv_zbukr TYPE i.
  DATA: lt_detail LIKE t_detail OCCURS 0 WITH HEADER LINE.

  CLEAR: lv_count.
  DESCRIBE TABLE t_detail LINES gv_rec.
  IF fu_zbukr EQ '8230'.
    lv_zbukr = 17.
    lv_mod  = gv_rec MOD lv_zbukr.
    IF lv_mod EQ 0 OR
      lv_mod GT 7.
      t_header-znew  = 'X'.
    ENDIF.
  ELSEIF fu_zbukr EQ '8050'.
    lv_zbukr = 30.
    lv_mod  = gv_rec MOD lv_zbukr.
    IF lv_mod EQ 0 OR
      lv_mod GT 28.
      t_header-znew  = 'X'.
    ENDIF.
  ENDIF.

  lt_detail[] = t_detail[].
  CLEAR: t_detail[].

  LOOP AT lt_detail.
    t_detail  = lt_detail.
    APPEND t_detail.
    IF t_header-znew EQ 'X'.
      ADD 1 TO lv_count.
      lv_calc = gv_rec - lv_count.
      IF lv_calc EQ 1.
        CLEAR: t_detail.
        lv_space  = lv_zbukr - lv_mod + 1.
        DO lv_space TIMES.
          APPEND t_detail.
        ENDDO.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_DETAIL

**&---------------------------------------------------------------------*
**&      Form  F_PREPARE_SAVE_DOCUMENT
**&---------------------------------------------------------------------*
*FORM f_prepare_save_document USING  fwa_acc STRUCTURE zfacc_receipt.
*  t_save-bukrs   = t_regup-zbukr.
*  t_save-pyord   = t_reguh-pyord.
*  t_save-laufd   = t_reguh-laufd.
*  t_save-laufi   = t_reguh-laufi.
*  t_save-lifnr   = t_reguh-lifnr.
*  t_save-belnr   = t_regup-belnr.
*  t_save-gjahr   = t_regup-gjahr.
*  t_save-buzei   = t_regup-buzei.
*  t_save-type    = fwa_acc-type.
*  t_save-hkont   = fwa_acc-hkont.
*  t_save-gsber   = t_regup-gsber.
*  CONCATENATE sy-uname sy-datum sy-uzeit INTO t_save-creator.
*  CONCATENATE t_regup-laufd '/' t_regup-laufi INTO t_save-bktxt.
*  t_save-xblnr   = t_regup-xblnr.
*  t_save-zuonr   = t_regup-belnr.
*  CONCATENATE fwa_acc-zdesc t_reguh-name1
*  INTO t_save-sgtxt SEPARATED BY space.
*  t_save-waers   = t_regup-waers.
*  t_save-shkzg   = t_bsis-shkzg.
*  t_save-wrbtr   = t_bsis-wrbtr.
*  t_save-blart   = 'SA'.
*  t_save-bschl   = '50'.
*  t_save-zform   = fwa_acc-zform.
*  READ TABLE t_lfa1 WITH KEY lifnr = t_reguh-lifnr.
*  IF sy-subrc EQ 0.
**    PERFORM f_modify_value USING t_lfa1-stceg
**                           CHANGING t_save-stceg.
*    t_save-stceg = t_lfa1-stceg.
*  ENDIF.
*  t_save-name1   = t_reguh-name1.
*  CONCATENATE t_reguh-stras t_reguh-ort01
*  INTO t_save-zaddress SEPARATED BY space.
*  CONCATENATE gv_nomor '/' fwa_acc-zrefbukti t_save-nobukti t_regup-gjahr
*  INTO t_save-nobukti.
*  t_save-zkdjasa   = fwa_acc-zkdjasa.
*  t_save-tarif     = t_bsis-wrbtr / ( t_regup-wrbtr + t_bsis-wrbtr ) * 100.
*  t_save-bruto     = t_regup-wrbtr.
*  t_save-pph       = t_bsis-wrbtr.
*  APPEND t_save.
*  CLEAR t_save.
*ENDFORM.                    " F_PREPARE_SAVE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  USING    fu_bukrs fu_gjahr
                        CHANGING fc_nomor.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZFPPH23'
      subobject               = fu_bukrs
      toyear                  = fu_gjahr
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

ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_value
                     CHANGING fc_value.
  DATA : lv_subrc     TYPE sy-subrc,
         lv_value(50).

  lv_value  = fu_value.

  WHILE lv_subrc IS INITIAL.
    REPLACE '-' WITH space INTO lv_value.
    lv_subrc  = sy-subrc.
  ENDWHILE.

  CLEAR lv_subrc.
  WHILE lv_subrc IS INITIAL.
    REPLACE '.' WITH space INTO lv_value.
    lv_subrc  = sy-subrc.
  ENDWHILE.

  CONDENSE lv_value NO-GAPS.
  fc_value  = lv_value.
ENDFORM.                    " F_MODIFY_VALUE
