*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_E0007F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .
  m_fldcat 'LIGHT' '' 'Indicator' '' 'L' '' 'CHAR' ''.
  m_fldcat 'STATUS' '' 'Status after posting (error/success)' '' 'L' '' 'CHAR' ''.
  m_fldcat 'DOC_NO' '' 'Doc No' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BLDAT' '' 'Document Date' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BLART' '' 'Document Type' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BUKRS' '' 'Company Code' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BUDAT' '' 'Posting Date' '' 'L' '' 'CHAR' ''.
  m_fldcat 'WAERS' '' 'Currency' '' 'R' '' 'CUKY' ''.
  m_fldcat 'KURSF' '' 'Exchange Rate Direct Quotation' '' 'R' '' 'CURR' ''.
  m_fldcat 'XBLNR' '' 'Reference' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BKTXT' '' 'Document Header Text' '' 'L' '' 'CHAR' ''.
  m_fldcat 'MONAT' '' 'Periode' '' 'L' '' 'CHAR' ''.
*  m_fldcat 'XMWST' '' 'Calculate tax' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BSCHL' '' 'Posting Key' '' 'L' '' 'CHAR' ''.
  m_fldcat 'HKONT' '' 'Account' '' 'L' '' 'CHAR' ''.
  m_fldcat 'UMSKZ' '' 'Special G/L Ind' '' 'L' '' 'CHAR' ''.
  m_fldcat 'DMBTR' '' 'Amount in LC' '' 'R' '' 'CURR' ''.
  m_fldcat 'WRBTR' '' 'Amount in DC' '' 'R' '' 'CURR' ''.
*  m_fldcat 'WMWST' '' 'Tax Amount' '' 'R' '' 'CURR' ''.
  m_fldcat 'KKBER' '' 'Credit Control Area' '' 'L' '' 'CHAR' ''.
  m_fldcat 'ZUONR' '' 'Asignment' '' 'L' '' 'CHAR' ''.
  m_fldcat 'SGTXT' '' 'Text' '' 'L' '' 'CHAR' ''.
  m_fldcat 'GSBER' '' 'Business Area' '' 'L' '' 'CHAR' ''.
  m_fldcat 'KOSTL' '' 'Cost Center' '' 'L' '' 'CHAR' ''.
  m_fldcat 'PROJK' '' 'WBS Element' '' 'L' '' 'CHAR' ''.
  m_fldcat 'FKBER' '' 'Functional Area' '' 'L' '' 'CHAR' ''.
  m_fldcat 'MATNR' '' 'Material' '' 'L' '' 'CHAR' ''.
  m_fldcat 'ZTERM' '' 'Terms of Payment' '' 'L' '' 'CHAR' ''.
  m_fldcat 'ZLSPR' '' 'Payment Blok Key' '' 'L' '' 'CHAR' ''.
  m_fldcat 'ZLSCH' '' 'Payment Method' '' 'L' '' 'CHAR' ''.
  m_fldcat 'PRCTR' '' 'Profit Center' '' 'L' '' 'CHAR' ''.
  m_fldcat 'REBZG' '' 'Invoice Reference' '' 'L' '' 'CHAR' ''.
  m_fldcat 'REBZJ' '' 'Fiscal Year of document' '' 'L' '' 'CHAR' ''.
  m_fldcat 'REBZZ' '' 'Line Item No in relevant doc' '' 'L' '' 'CHAR' ''.
  m_fldcat 'KIDNO' '' 'Payment Reference' '' 'L' '' 'CHAR' ''.
  m_fldcat 'VALUT' '' 'Value Date' '' 'L' '' 'CHAR' ''.
  m_fldcat 'ZFBDT' '' 'Baseline Date' '' 'L' '' 'CHAR' ''.
  m_fldcat 'AUFNR' '' 'Internal Order' '' 'L' '' 'CHAR' ''.
*  m_fldcat 'MWSKZ' '' 'Tax Code' '' 'L' '' 'CHAR' ''.
  m_fldcat 'BUPLA' '' 'Business Place' '' 'L' '' 'CHAR' ''.
  m_fldcat 'XREF1' '' 'Business Partner Reference Key(1)' '' 'L' '' 'CHAR' ''.
  m_fldcat 'XREF2' '' 'Business Partner Reference Key(2)' '' 'L' '' 'CHAR' ''.
  m_fldcat 'XREF3' '' 'Reference Key for Line Item' '' 'L' '' 'CHAR' ''.
  m_fldcat 'MWSKZ' '' 'Tax Code' '' 'L' '' 'CHAR' ''.
ENDFORM. " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_layout .
  x_layout-colwidth_optimize  = 'X'.
  x_layout-info_fieldname     = 'LINE_COLOR'.
ENDFORM. " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_STATUS_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM f_status_set USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING rt_extab.
ENDFORM. " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event .
  REFRESH: t_events.
  CLEAR t_events.
  t_events-name = slis_ev_user_command.
  t_events-form = 'USER_COMMAND'.
  APPEND t_events.

  CLEAR t_events.
  t_events-name = slis_ev_pf_status_set.
  t_events-form = 'F_STATUS_SET'.
  APPEND t_events.

  CLEAR t_events.
  t_events-name = slis_ev_top_of_page.
  t_events-form = 'F_TOP_OF_PAGE'.
  APPEND t_events.

*  CLEAR t_events.
*  t_events-name = slis_ev_end_of_page.
*  t_events-form = 'F_END_OF_PAGE'.
*  APPEND t_events.
ENDFORM. " F_BUILD_EVENT

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  DATA : lv_answer(1) TYPE c.
  CASE r_ucomm.
    WHEN '&SIM'. "simulate
      PERFORM f_posting_data USING r_ucomm.
      rs_selfield-refresh = 'X'.
    WHEN '&POS'. "posting
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'G/L Mass Posting'
          text_question  = 'Are you sure to post ?'
          text_button_1  = 'Yes'
          text_button_2  = 'No'
          start_column   = 25
          start_row      = 6
        IMPORTING
          answer         = lv_answer
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc EQ 0 AND lv_answer = '1'.
        PERFORM f_posting_data USING r_ucomm.
        rs_selfield-refresh = 'X'.
      ENDIF.
    WHEN '&PARK'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'G/L Mass Park'
          text_question  = 'Are you sure to park ?'
          text_button_1  = 'Yes'
          text_button_2  = 'No'
          start_column   = 25
          start_row      = 6
        IMPORTING
          answer         = lv_answer
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc EQ 0 AND lv_answer = '1'.
        PERFORM f_posting_bdc USING r_ucomm.
        rs_selfield-refresh = 'X'.
      ENDIF.
  ENDCASE.
ENDFORM. "user_command

*&---------------------------------------------------------------------*
*&      Form  set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*      -->ENDFORM    text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS_1000' EXCLUDING rt_extab.
ENDFORM. "set_pf_status
*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page.
  DATA : lt_info  TYPE slis_t_listheader WITH HEADER LINE.
  DATA : lv_date  TYPE char10,
         lv_bulan TYPE char30.

  CLEAR lt_info.
  lt_info-typ  = 'H'.
  lt_info-info = sy-title.
  APPEND lt_info.

  CLEAR lt_info.
  lt_info-typ  = 'S'.
  lt_info-key  = 'User :'.
  lt_info-info = sy-uname.
  APPEND lt_info.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_info[].

ENDFORM. "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_event_exit .

*  clear t_event_exit.
*  t_event_exit-ucomm = '&OUP'.
*  t_event_exit-after = 'X'.
*  append t_event_exit.

ENDFORM. " F_BUILD_EVENT_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_print .

  x_print-no_print_listinfos = 'X'.
  x_print-no_print_selinfos  = 'X'.
  x_print-no_coverpage       = 'X'.
  x_print-no_print_hierseq_item = 'X'.

ENDFORM. " F_BUILD_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_sort .

*  CLEAR t_sort.
*  t_sort-fieldname = 'KUNNR'.
*  t_sort-up        = 'X'.
*  t_sort-group     = 'UL'.
*  t_sort-subtot    = 'X'.
*  APPEND t_sort.

ENDFORM. " F_BUILD_SORT


*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM. "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_BDC
*&---------------------------------------------------------------------*
FORM f_posting_bdc  USING    p_r_ucomm.

ENDFORM.                    " F_POSTING_BDC
