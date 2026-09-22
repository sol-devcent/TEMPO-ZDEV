*&---------------------------------------------------------------------*
*& Report  ZFI_CASH_PAYMENT_VOUCHER
*&
*&---------------------------------------------------------------------*
*& Program Name     : ZFI_CASH_PAYMENT_VOUCHER
*& Module Name      : FI
*& Author           : IBM-Taufik Nuril
*& Create Date      : 16/06/2015
*& Program Type     : Forms
*& SAP Release      : ECC6
*& Description      : Form yang digunakan untuk permintaan pembayaran
*&                    kepada Treasury
*&---------------------------------------------------------------------*
*& REVISION LOG
*&
*& LOG#       DATE     AUTHOR            DESCRIPTION
*& ----       ----     ------            -----------
*& DEVK943615 16/06/15 IBM-TAUFIK_NURIL  Initial Implementation
*& DEVK943800 22/06/15 IBM-TAUFIK_NURIL  - BKPF additional restriction for tune performance
*&                                       - redefine smartforms vendor column and header
*& DEVK944594 23/07/15 IBM-POHAN         Fix loop in smartforms
*&---------------------------------------------------------------------*

REPORT  zfi_cash_payment_voucher.
TYPE-POOLS slis.
TABLES reguh.

DEFINE m_set_fcatalog.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = &1.
  gs_fieldcat-seltext_m = &2.
  gs_fieldcat-outputlen = &3.
  gs_fieldcat-key       = &4.
  IF &1 EQ 'PSWBT'.     "to put hot spot for detail objectives
    gs_fieldcat-do_sum = 'X'.
    gs_fieldcat-decimals_out = &5.
  ENDIF.
  APPEND gs_fieldcat TO gt_fieldcat.
END-OF-DEFINITION.

DEFINE m_set_header_alv.
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = &1.
  ls_line-info = &2.
  APPEND ls_line TO lt_top_of_page.
END-OF-DEFINITION.

DATA: gd_ucomm TYPE sy-ucomm.
DATA: BEGIN OF tab_laufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
      DATA: END OF tab_laufk.
DATA p_display_alv.
DATA: BEGIN OF t_alv OCCURS 0,
*        xsel(1),
        zbukr TYPE regup-bukrs,
        butxt TYPE t001-butxt,
        laufd TYPE reguh-laufd,
        laufi TYPE reguh-laufi,
        lifnr TYPE reguh-lifnr,
        name1 TYPE reguh-name1,
        pyord TYPE reguh-pyord,
        gjahr TYPE regup-gjahr,
        belnr TYPE regup-belnr,
        zfbdt TYPE regup-zfbdt,
        xblnr TYPE bkpf-xblnr,
        sgtxt TYPE bsik-sgtxt,
        pswsl TYPE regup-pswsl,
        pswbt TYPE wmto_s-amount, "regup-pswbt,
      END OF t_alv.
DATA lt_reguh LIKE reguh OCCURS 0 WITH HEADER LINE.
DATA lt_t001 LIKE t001 OCCURS 0 WITH HEADER LINE.
DATA lt_regup LIKE regup OCCURS 0 WITH HEADER LINE.
DATA lt_lfa1 LIKE lfa1 OCCURS 0 WITH HEADER LINE.
DATA lt_bkpf LIKE bkpf OCCURS 0 WITH HEADER LINE.
DATA lt_bsik LIKE bsik OCCURS 0 WITH HEADER LINE.
DATA: gt_list_top_of_page TYPE slis_t_listheader,
      gt_events           TYPE slis_t_event WITH HEADER LINE,
      gw_layout           TYPE slis_layout_alv,
      gs_fieldcat         TYPE slis_fieldcat_alv,
      gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE.
DATA d_ismultiple.
DATA d_stop.


SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text01 NO INTERVALS.
PARAMETERS: p_laufd LIKE reguh-laufd OBLIGATORY,
            p_laufi LIKE reguh-laufi OBLIGATORY.
*SELECT-OPTIONS s_lifnr FOR reguh-lifnr.
SELECTION-SCREEN END OF BLOCK b01.

*SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text02 NO INTERVALS.
*PARAMETERS: p_banknm TYPE c LENGTH 30 LOWER CASE,
*            p_cheknm TYPE c LENGTH 30,
*            p_acctnm TYPE c LENGTH 30.
*SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE text03.
PARAMETERS: r1      RADIOBUTTON GROUP rad1 DEFAULT 'X' USER-COMMAND upd,
            r2      RADIOBUTTON GROUP rad1,
            p_name1 TYPE c LENGTH 40 MODIF ID h1 LOWER CASE.
SELECTION-SCREEN END OF BLOCK b03.


INITIALIZATION.
  text01                   = 'Settlement Selection'.
  %_p_laufd_%_app_%-text   = 'Run Date'.
  %_p_laufi_%_app_%-text   = 'Identification'.
*  %_s_lifnr_%_app_%-text   = 'Vendor Number'.

*  text02                   = 'Additional Information'.
*  %_p_banknm_%_app_%-text   = 'Bank Name'.
*  %_p_cheknm_%_app_%-text   = 'Cheque Number'.
*  %_p_acctnm_%_app_%-text   = 'Bank A/C Number'.

  text03                   = 'Payment Method'.
  %_r1_%_app_%-text   = 'Single Vendor in One Voucher'.
  %_r2_%_app_%-text   = 'Multiple Vendor in One Voucher'.
  %_p_name1_%_app_%-text   = 'Dibayar kepada'.


AT SELECTION-SCREEN.
  gd_ucomm = sy-ucomm.
  PERFORM f_init_laufk.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen.
  PERFORM f_determine_method.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_laufd.
  PERFORM f_fill_parameters.

START-OF-SELECTION.
  IF r2 EQ 'X'.
    IF p_name1 IS INITIAL.
      MESSAGE 'Dibayarkan Kepada harus diisi' TYPE 'I'.
      MOVE 'X' TO d_stop.
    ENDIF.
  ENDIF.
  CHECK d_stop IS INITIAL.
  PERFORM f_get_data.
  PERFORM f_display_alv.
*  IF p_display_alv EQ 'X'.
*    PERFORM f_display_alv.
*  ELSE.
**    PERFORM f_print_preview.
*  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen .
  IF gd_ucomm EQ 'UPD' OR gd_ucomm EQ space.
    IF r1 EQ 'X'.
      LOOP AT SCREEN.
        IF screen-group1 = 'H1'.
          screen-active = '0'.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_FILL_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fill_parameters .
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'P_LAUFI'
    IMPORTING
      laufd = p_laufd
      laufi = p_laufi
    TABLES
      laufk = tab_laufk.
ENDFORM.                    " F_FILL_PARAMETERS


*&---------------------------------------------------------------------*
*&      Form  F_INIT_LAUFK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_laufk .
  CLEAR tab_laufk[].
  tab_laufk-laufk = 'W'.
  tab_laufk-sign  = 'E'.
  APPEND tab_laufk.
ENDFORM.                    " F_INIT_LAUFK


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA ld_reguh_count TYPE i.
  SELECT * FROM reguh INTO TABLE lt_reguh
    WHERE laufd EQ p_laufd
      AND laufi EQ p_laufi
      AND xvorl EQ space.

  CHECK lt_reguh[] IS NOT INITIAL.
  SELECT * FROM t001 INTO TABLE lt_t001
    FOR ALL ENTRIES IN lt_reguh
    WHERE bukrs EQ lt_reguh-zbukr.

  SELECT * FROM lfa1 INTO TABLE lt_lfa1
    FOR ALL ENTRIES IN lt_reguh
    WHERE lifnr EQ lt_reguh-lifnr.

  SELECT * FROM regup INTO TABLE lt_regup
    FOR ALL ENTRIES IN lt_reguh
    WHERE laufd EQ lt_reguh-laufd
      AND laufi EQ lt_reguh-laufi
      AND zbukr EQ lt_reguh-zbukr
      AND vblnr EQ lt_reguh-vblnr
      AND xvorl EQ space.

  SELECT * FROM bkpf INTO TABLE lt_bkpf
    FOR ALL ENTRIES IN lt_regup
    WHERE belnr EQ lt_regup-belnr
      AND gjahr EQ lt_regup-gjahr
      AND bukrs EQ lt_regup-bukrs.

  SELECT * FROM bsik INTO TABLE lt_bsik
    FOR ALL ENTRIES IN lt_regup
    WHERE bukrs EQ lt_regup-zbukr
      AND lifnr EQ lt_regup-lifnr
      AND belnr EQ lt_regup-belnr
      AND gjahr EQ lt_regup-gjahr
      AND buzei EQ lt_regup-buzei
    .

*  DESCRIBE TABLE lt_reguh LINES ld_reguh_count.
*  IF ld_reguh_count NE 0.
*    MOVE 'X' TO p_display_alv.
*  ENDIF.

  LOOP AT lt_regup.
    CLEAR t_alv.

    DATA d_amount TYPE wmto_s-amount.
    DATA d_amount_i TYPE wmto_s-amount.

    IF lt_regup-shkzg EQ 'S'.
      d_amount_i = lt_regup-pswbt * -1.
    ELSE.
      d_amount_i = lt_regup-pswbt.
    ENDIF.

    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        currency        = lt_regup-pswsl
        amount_internal = d_amount_i
      IMPORTING
        amount_display  = d_amount
      EXCEPTIONS
        internal_error  = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    t_alv-zbukr = lt_regup-bukrs.
    t_alv-belnr = lt_regup-belnr.
    t_alv-zfbdt = lt_regup-zfbdt + lt_regup-zbd1t.
    t_alv-pswsl = lt_regup-pswsl.
    t_alv-pswbt = d_amount.
    t_alv-gjahr = lt_regup-gjahr.

    CLEAR lt_bsik.
    READ TABLE lt_bsik WITH KEY bukrs = lt_regup-zbukr
                                lifnr = lt_regup-lifnr
                                belnr = lt_regup-belnr
                                buzei = lt_regup-buzei
                                gjahr = lt_regup-gjahr.
    t_alv-sgtxt = lt_bsik-sgtxt.

    CLEAR lt_bkpf.
    READ TABLE lt_bkpf WITH KEY belnr = lt_regup-belnr.
    t_alv-xblnr = lt_bkpf-xblnr.

    CLEAR lt_reguh.
    READ TABLE lt_reguh WITH KEY laufd = lt_regup-laufd
                                 laufi = lt_regup-laufi
                                 zbukr = lt_regup-zbukr
                                 vblnr = lt_regup-vblnr.
    IF sy-subrc EQ 0.
      t_alv-laufd = lt_reguh-laufd.
      t_alv-laufi = lt_reguh-laufi.
      t_alv-lifnr = lt_reguh-lifnr.
      t_alv-name1 = lt_reguh-name1.
      t_alv-pyord = lt_reguh-pyord.

      READ TABLE lt_t001 WITH KEY bukrs = lt_reguh-zbukr.
      t_alv-butxt = lt_t001-butxt.
    ENDIF.

    APPEND t_alv.
  ENDLOOP.

ENDFORM.                    " F_GET_DATA


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .
  PERFORM f_set_fieldcat.
  PERFORM f_set_layout.
  PERFORM f_set_event.
  PERFORM f_set_comment USING gt_list_top_of_page[].
  PERFORM f_call_alv.
ENDFORM.                    " F_DISPLAY_ALV


*&---------------------------------------------------------------------*
*&      Form  F_SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_fieldcat .
  m_set_fcatalog:
    'ZBUKR'     'Paying Comp Code'          '20'  'X' '',
    'BUTXT'     'Comp Name'          '20'  'X' '',
    'LAUFD'     'Date'                '10'  'X' '',
    'LAUFI'     'Run No'          '10'  'X' '',
    'LIFNR'     'Vendor No'          '10'  '' '',
    'NAME1'     'Vendor Name'          '20'  '' '',
    'PYORD'     'Pay Order'          '10'  '' '',
    'GJAHR'     'Doc Year'          '10'  '' '',
    'BELNR'     'Doc Num'          '10'  '' '',
    'ZFBDT'     'Due Date'          '10'  '' '',
    'SGTXT'     'Note'          '30'  '' '',
    'PSWSL'     'Curr'          '10'  '' '',
    'PSWBT'     'Amount'          '10'  '' 2.
ENDFORM.                    " F_SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_layout .
  gw_layout-zebra             = 'X'.
  gw_layout-no_input          = 'X'.
  gw_layout-colwidth_optimize = 'X'.
  gw_layout-cell_merge        = 'X'.
*  gw_layout-box_fieldname     = 'XSEL'.
ENDFORM.                    " F_SET_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_SET_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_event .
  REFRESH gt_events.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events[].
  LOOP AT gt_events.
    CASE gt_events-name.
      WHEN slis_ev_top_of_page.
        MOVE 'F_TOP_OF_PAGE' TO gt_events-form.
    ENDCASE.
    MODIFY gt_events.
  ENDLOOP.
ENDFORM.                    " F_SET_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_SET_COMMENT
*&---------------------------------------------------------------------*
*&      ALV title
*&----------------------------------------------------------------------*
FORM f_set_comment USING lt_top_of_page TYPE slis_t_listheader.
  DATA ls_line TYPE slis_listheader.
  DATA ld_date(30).

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  IF r1 EQ 'X'.
    ls_line-info = 'Single Vendor in One Voucher'.
  ENDIF.
  IF r2 EQ 'X'.
    ls_line-info = 'Multiple Vendors in One Voucher'.
  ENDIF.
  APPEND ls_line TO lt_top_of_page.

  READ TABLE t_alv INDEX  1.
  CONCATENATE t_alv-laufd+6(2) t_alv-laufd+4(2) t_alv-laufd+0(4) INTO ld_date SEPARATED BY '.'.
  CONCATENATE ld_date t_alv-laufi INTO ld_date SEPARATED BY '/'.
  SHIFT t_alv-pyord LEFT DELETING LEADING '0'.

  m_set_header_alv:
    'Comp Code'             t_alv-zbukr,
    'Comp Name'             t_alv-butxt,
    'Tanggal Proposal/ID'   ld_date,
    'No Pembayaran'         t_alv-pyord.
*    'Nama Bank'             p_banknm,
*    'Cheque Number'         p_cheknm,
*    'No Rek Bank'           p_acctnm.

  IF r2 EQ 'X'.
    m_set_header_alv 'Dibayarkan Kepada' p_name1.
  ENDIF.
ENDFORM. " F_SET_COMMENT

*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
*     i_logo             = 'LOGO'
      it_list_commentary = gt_list_top_of_page.
ENDFORM. "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_CALL_ALV
*&---------------------------------------------------------------------*
*&      Call alv function
*&----------------------------------------------------------------------*
FORM f_call_alv .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-cprog
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      i_callback_user_command  = 'HANDLE_USER_COMMAND'
      i_callback_pf_status_set = 'HANDLE_MENU'
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
      it_events                = gt_events[]
      i_default                = 'X'
      i_save                   = 'A'
      it_sort                  = gt_sort[]
    TABLES
      t_outtab                 = t_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM. " F_CALL_ALV

*---------------------------------------------------------------------*
*       FORM handle_user_command                                              *
*---------------------------------------------------------------------*
FORM handle_user_command USING r_ucomm LIKE sy-ucomm
                               rs_selfield TYPE slis_selfield.

  DATA ld_int_formname TYPE rs38l_fnam.
  DATA control TYPE ssfctrlop.
  DATA ssfcompop TYPE  ssfcompop.
  DATA ssfcompin TYPE ssfcompin.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZDG2FI_010RS'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = ld_int_formname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  CASE sy-ucomm.
    WHEN '&ZPRI'.
      control-no_dialog = 'X'.
      control-preview   = 'X'.
      control-no_open   = 'X'.
      control-no_close  = 'X'.


      CALL FUNCTION 'SSF_OPEN'
        EXPORTING
*         ARCHIVE_PARAMETERS =
*         USER_SETTINGS      = 'X'
*         MAIL_SENDER        =
*         MAIL_RECIPIENT     =
*         MAIL_APPL_OBJ      =
*         OUTPUT_OPTIONS     =
          control_parameters = control
*   IMPORTING
*         JOB_OUTPUT_OPTIONS =
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ENDIF.

      BREAK dg2_co01.

      IF r1 EQ 'X'.
        LOOP AT lt_reguh.
          DATA lt_reguh_sf LIKE reguh OCCURS 0 WITH HEADER LINE.
          CLEAR lt_reguh_sf[].
          APPEND lt_reguh TO lt_reguh_sf.

          CALL FUNCTION ld_int_formname
            EXPORTING
*             ARCHIVE_INDEX      =
*             ARCHIVE_INDEX_TAB  =
*             ARCHIVE_PARAMETERS =
              control_parameters = control
*             MAIL_APPL_OBJ      =
*             MAIL_RECIPIENT     =
*             MAIL_SENDER        =
              output_options     = ssfcompop
*             USER_SETTINGS      = 'X'
              d_multiple         = d_ismultiple
              d_byr_kpd          = p_name1
* IMPORTING
*             DOCUMENT_OUTPUT_INFO       =
*             JOB_OUTPUT_INFO    =
*             JOB_OUTPUT_OPTIONS =
            TABLES
              t_reguh            = lt_reguh_sf
              t_t001             = lt_t001
              t_lfa1             = lt_lfa1
              t_bkpf             = lt_bkpf
              t_regup            = lt_regup
              t_bsik             = lt_bsik
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

          IF r2 EQ 'X'.
            EXIT.
          ENDIF.

        ENDLOOP.
      ELSE.
        CALL FUNCTION ld_int_formname
          EXPORTING
*           ARCHIVE_INDEX      =
*           ARCHIVE_INDEX_TAB  =
*           ARCHIVE_PARAMETERS =
            control_parameters = control
*           MAIL_APPL_OBJ      =
*           MAIL_RECIPIENT     =
*           MAIL_SENDER        =
            output_options     = ssfcompop
*           USER_SETTINGS      = 'X'
            d_multiple         = d_ismultiple
            d_byr_kpd          = p_name1
* IMPORTING
*           DOCUMENT_OUTPUT_INFO       =
*           JOB_OUTPUT_INFO    =
*           JOB_OUTPUT_OPTIONS =
          TABLES
            t_reguh            = lt_reguh
            t_t001             = lt_t001
            t_lfa1             = lt_lfa1
            t_bkpf             = lt_bkpf
            t_regup            = lt_regup
            t_bsik             = lt_bsik
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

      CALL FUNCTION 'SSF_CLOSE'
* IMPORTING
*   JOB_OUTPUT_INFO        =
        EXCEPTIONS
          formatting_error = 1
          internal_error   = 2
          send_error       = 3
          OTHERS           = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '&PDF'.
      PERFORM f_pdf_form.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "handle_user_command

*---------------------------------------------------------------------*
*       FORM handle_menu                                              *
*---------------------------------------------------------------------*
FORM handle_menu USING rt_extab TYPE slis_t_extab.
*  SET PF-STATUS 'PF_100'.

  DATA(lv_bukrs) = VALUE #( t_alv[ 1 ]-zbukr OPTIONAL ).
  IF lv_bukrs = '8180'.
    SET PF-STATUS 'PF_100'.
  ELSE.
    SET PF-STATUS 'PF_100' EXCLUDING '&PDF'.
  ENDIF.
ENDFORM.                    "handle_menu


*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_METHOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_method .

  IF r1 EQ 'X'.
    CLEAR d_ismultiple.
  ENDIF.

  IF r2 EQ 'X'.
    MOVE 'X' TO d_ismultiple.
  ENDIF.

ENDFORM.                    " F_DETERMINE_METHOD

*&---------------------------------------------------------------------*
*&      Form  F_PDF_FORM
*&---------------------------------------------------------------------*
FORM f_pdf_form .
  DATA: lt_reguh_sf LIKE reguh OCCURS 0 WITH HEADER LINE.

  DATA: cs_return        TYPE ssfcrescl.

  DATA: formname TYPE tdsfname VALUE 'ZDG2FI_010PDF',
        fmname   TYPE rs38l_fnam.

  DATA: lc_pdf     TYPE sopcklsti1-doc_type VALUE 'PDF',
        lt_otf     TYPE STANDARD TABLE OF itcoo,
        lv_objlen  TYPE sood-objlen,
        lv_xstring TYPE xstring,
        lt_lines   TYPE TABLE OF tline,
        lt_objbin  TYPE TABLE OF solix.

  DATA : directory   TYPE string,
         lv_filename TYPE string,
         document    TYPE string.

  DATA: op_option TYPE ssfctrlop.

* ->Get smartform function module name
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = formname
    IMPORTING
      fm_name            = fmname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  op_option-getotf = 'X'.
  op_option-no_dialog = 'X'.
  op_option-preview = space.

* -> Call smartform
  CASE 'X'.
    WHEN r1.
      LOOP AT lt_reguh.
        AT FIRST.
          op_option-no_close = 'X'.
        ENDAT.

        AT LAST.
          op_option-no_close = space.
        ENDAT.

        CLEAR lt_reguh_sf[].
        APPEND lt_reguh TO lt_reguh_sf.

        CALL FUNCTION fmname
          EXPORTING
            control_parameters = op_option
*           OUTPUT_OPTIONS     =
*           USER_SETTINGS      = 'X'
            d_multiple         = d_ismultiple
            d_byr_kpd          = p_name1
          IMPORTING
            job_output_info    = cs_return
          TABLES
            t_reguh            = lt_reguh_sf
            t_t001             = lt_t001
            t_lfa1             = lt_lfa1
            t_bkpf             = lt_bkpf
            t_regup            = lt_regup
            t_bsik             = lt_bsik
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

        op_option-no_open = 'X'.
      ENDLOOP.

      lv_filename = 'Single Vendor.pdf'.

    WHEN r2.
      CALL FUNCTION fmname
        EXPORTING
          control_parameters = op_option
*         OUTPUT_OPTIONS     =
*         USER_SETTINGS      = 'X'
          d_multiple         = d_ismultiple
          d_byr_kpd          = p_name1
        IMPORTING
          job_output_info    = cs_return
        TABLES
          t_reguh            = lt_reguh
          t_t001             = lt_t001
          t_lfa1             = lt_lfa1
          t_bkpf             = lt_bkpf
          t_regup            = lt_regup
          t_bsik             = lt_bsik
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

      lv_filename = 'Multiple Vendor.pdf'.
  ENDCASE.

*->Convert OTF output to PDF
  lt_otf[] = cs_return-otfdata[].

  IF lt_otf[] IS NOT INITIAL.
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = lc_pdf
        max_linewidth         = 134
      IMPORTING
        bin_filesize          = lv_objlen
        bin_file              = lv_xstring
      TABLES
        otf                   = lt_otf
        lines                 = lt_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

*->Convert xstring to binary
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_xstring
      TABLES
        binary_tab = lt_objbin[].

*->Get SAP directory
    CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
      CHANGING
        sapworkdir            = directory
      EXCEPTIONS
        get_sapworkdir_failed = 1
        cntl_error            = 2
        error_no_gui          = 3
        not_supported_by_gui  = 4
        OTHERS                = 5.

    IF sy-subrc = 0.
      CONCATENATE directory '\' lv_filename INTO document.

      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          filename                = document
          filetype                = 'BIN'
        CHANGING
          data_tab                = lt_objbin
        EXCEPTIONS
          file_write_error        = 1
          no_batch                = 2
          gui_refuse_filetransfer = 3
          invalid_type            = 4
          no_authority            = 5
          unknown_error           = 6
          header_not_allowed      = 7
          separator_not_allowed   = 8
          filesize_not_allowed    = 9
          header_too_long         = 10
          dp_error_create         = 11
          dp_error_send           = 12
          dp_error_write          = 13
          unknown_dp_error        = 14
          access_denied           = 15
          dp_out_of_memory        = 16
          disk_full               = 17
          dp_timeout              = 18
          file_not_found          = 19
          dataprovider_exception  = 20
          control_flush_error     = 21
          not_supported_by_gui    = 22
          error_no_gui            = 23
          OTHERS                  = 24.

      IF sy-subrc = 0.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = document
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
