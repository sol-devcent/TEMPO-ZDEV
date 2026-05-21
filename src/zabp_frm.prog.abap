*----------------------------------------------------------------------*
*   INCLUDE ZIBM_FRM                                                   *
*----------------------------------------------------------------------*
* @data
DATA: d_frm_subrc LIKE sy-subrc,  " general return code
      d_frm_layout LIKE tsp1d-papart VALUE 'X_65_255',
      d_frm_batch LIKE sy-batch,
      d_frm_first,
      d_frm_spage TYPE i,
      d_frm_indic(150),  "Display message in SAPGUI process indicator
      d_frm_memvl(12),
      d_frm_memid(11), " memory id (UNAME+CPROG+MODNO)
      d_frm_tabix LIKE sy-tabix,
      d_frm_index LIKE sy-index.
DATA: d_job_output_info TYPE ssfcrescl.

* @enddata

* @constanta
CONSTANTS:
     c_frm_yes VALUE '1',
     c_frm_no VALUE '0'.
* @endconstanta

*-----------------------------------------------------------------------
* @form        F_FRM_DATE2TEXT
* @description convert SAP-Date type to text
* @param       FU_DATE
* @par-desc    like SY-DATUM
* @param       FC_TEXT_DATE
* @par-desc    type CHAR, length 10
*-----------------------------------------------------------------------
FORM f_frm_date2text USING fu_date
                 CHANGING fc_text_date.
  WRITE fu_date TO fc_text_date DD/MM/YYYY.
ENDFORM.

*-----------------------------------------------------------------------
* @form        F_FRM_TEXT2DATE
* @description convert text to SAP-Date type
* @param       FC_TEXT_DATE
* @par-desc    type CHAR, length 10
* @param       FU_DATE
* @par-desc    like SY-DATUM
*-----------------------------------------------------------------------
FORM f_frm_text2date USING fu_text_date
                 CHANGING fc_date.
*  FC_DATE+6(2) = FU_TEXT_DATE+(2).
*  FC_DATE+4(2) = FU_TEXT_DATE+3(2).
*  FC_DATE+(4)  = FU_TEXT_DATE+6(4).
  WRITE fu_text_date TO fc_date YYMMDD.
ENDFORM.

*-----------------------------------------------------------------------
* @form        F_FRM_DISPLAY_INDICATOR
* @description to display text indicator
* @param       FU_TEXT
* @par-desc    text to display
* @param       FU_PERCENTAGE
* @par-desc    percentage counter
* @par-val     SPACE - not showing percentage indicator
*-----------------------------------------------------------------------
FORM f_frm_display_indicator USING fu_text fu_percentage.
  DATA: ld_percentage TYPE i.
  IF fu_percentage = space.
    ld_percentage = 0.
  ELSE.
    MOVE fu_percentage TO ld_percentage.
  ENDIF.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = ld_percentage
            text       = fu_text.
ENDFORM.                    " F_DISPLAY_INDICATOR

*-----------------------------------------------------------------------
* @form        F_FRM_ADD_MONTH
* @description add month to a date
* @param       FU_DATE
* @par-desc    date to calculate
* @param       FU_MONTH
* @par-desc    month to add
* @param       FC_CALC_DATE
* @par-desc    the result
*-----------------------------------------------------------------------
FORM f_frm_add_month USING fu_date LIKE sy-datum
                           fu_month TYPE i
                     CHANGING fc_calc_date LIKE sy-datum.
  DATA: ld_month TYPE i, ld_year TYPE i, ld_rest_month TYPE i,
        ld_calc_day(2) TYPE n, ld_calc_month(2) TYPE n,
        ld_calc_year(4) TYPE n.
  ld_month = fu_date+4(2).
  ld_rest_month = 12 - ld_month.
  IF ld_rest_month >= fu_month.
    ld_rest_month = ld_month + fu_month.
    CLEAR ld_year.
  ELSE.
    DATA: ld_m_f TYPE f.
    ld_month = fu_month - ld_rest_month.
    IF ld_month <= 12.
      ld_rest_month = ld_month.
      CLEAR ld_year.
    ELSE.
      ld_m_f = ld_month.
      ld_m_f = ld_m_f / 12.
      ld_year = floor( ld_month / 12 ).
      ld_year = floor( ld_m_f ).
      ld_rest_month = ld_month - ( ld_year * 12 ).
    ENDIF.
    ld_year = ld_year + 1.
  ENDIF.

  ld_calc_day = fu_date+6(2).
  ld_calc_month = ld_rest_month.
  ld_calc_year = fu_date(4).
  ld_calc_year = ld_calc_year + ld_year.

  CONCATENATE ld_calc_year ld_calc_month ld_calc_day
        INTO fc_calc_date.
ENDFORM.

*-----------------------------------------------------------------------
* @form        F_FRM_BEGIN_END_MONTH
* @description Get begin and end date from one month
*              if wrong month entered, D_FRM_SUBRC = 4
* @param       FU_MONTH
* @par-desc    month to calculate
* @param       FU_YEAR
* @par-desc    year to calculate
* @param       FC_BEGINDATE
* @par-desc    begin date from entered month.year
* @param       FC_ENDDATE
* @par-desc    end date from entered month.year
*-----------------------------------------------------------------------
FORM f_frm_begin_end_month USING fu_month
                                 fu_year
                           CHANGING fc_begindate
                                    fc_enddate.
  CLEAR: fc_begindate, fc_enddate, d_frm_subrc.
  IF fu_month >= 1 AND fu_month <= 12.
    CONCATENATE fu_year fu_month '01' INTO fc_begindate.
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
         EXPORTING
              day_in            = fc_begindate
         IMPORTING
              last_day_of_month = fc_enddate
         EXCEPTIONS
              day_in_no_date    = 1
              OTHERS            = 2.
  ELSE.
    d_frm_subrc = 4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_FRM_SCROLL_PAGE
*&---------------------------------------------------------------------*
DEFINE macro_frm_scroll_page.
  d_frm_spage = &1.
  describe table &3 lines sy-tfill.
  case sy-ucomm.
    when 'P-- '. d_frm_spage = 1.
    when 'P-  '.
      d_frm_spage = d_frm_spage - &2.
      if d_frm_spage < 0.
        d_frm_spage = 1.
      endif.
    when 'P+  '.
      d_frm_spage = d_frm_spage + &2.
      if d_frm_spage >= sy-tfill.
        d_frm_spage = sy-tfill.
      endif.
    when 'P++ '. d_frm_spage = sy-tfill.
  endcase.
  &1 = d_frm_spage.
END-OF-DEFINITION.                               " F_FRM_SCROLL_PAGE

*-----------------------------------------------------------------------
* @form        F_FRM_HELP_POPUP
* @description Display message at Help popup window
* @param       FU_ATEXT
* @par-desc    Message will be displayed at popup window
*-----------------------------------------------------------------------
FORM f_frm_help_popup USING fu_cprog fu_dynnr fu_msgid fu_atext.
  DATA: lt_info LIKE help_info OCCURS 0 WITH HEADER LINE,
        lt_dselc LIKE dselc OCCURS 0 WITH HEADER LINE,
        lt_dval LIKE dval OCCURS 0 WITH HEADER LINE,
        ld_select_value LIKE help_info-fldvalue,
        ld_selection,
        ld_rsmdy LIKE rsmdy.

  lt_info-call = 'D'.
  lt_info-object = 'N'.
  lt_info-program = fu_cprog.
  lt_info-dynpro = fu_dynnr.
  lt_info-spras = sy-langu.
  lt_info-message = fu_atext.
  lt_info-docuid = 'NA'.
  lt_info-title = 'Display_Batch_Input_Error-message'.
  lt_info-messageid = fu_msgid.

  CALL FUNCTION 'HELP_START'
       EXPORTING
            help_infos   = lt_info
       IMPORTING
            selection    = ld_selection
            select_value = ld_select_value
            rsmdy_ret    = ld_rsmdy
       TABLES
            dynpselect   = lt_dselc
            dynpvaluetab = lt_dval
       EXCEPTIONS
            OTHERS       = 1.
ENDFORM.
