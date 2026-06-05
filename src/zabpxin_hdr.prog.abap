DATA:
  d_hdr_rpt_lines VALUE 'X',
  d_hdr_selection(50),
  d_hdr_rpos TYPE i,
  d_hdr_lines TYPE i,
  d_hdr_types,
  d_hdr_intsf,   "Flag for intensified
  d_hdr_low(30),
  d_hdr_high(30),
  d_hdr_atext(80),
  d_hdr_lngth TYPE i,
  d_hdr_title(999),           " Report title with padding
  d_hdr_text1(999),           " User text 1
  d_hdr_text2(999),           " User text 2
  d_hdr_text3(999).           " User text 3

DATA: d_hdr_begrtime TYPE i,
      d_hdr_endrtime TYPE i,
      d_hdr_rtime(15) VALUE 'HH:MM:SS,mm'.

*&---------------------------------------------------------------------*
*&      Macro  m_hdr_show_selection_value
*&---------------------------------------------------------------------*
* Display value of SELECT-OPTIONS
* &1 => cursor position
* &2 => decription
* &3 => internal table from selection screen
* &4 => L = left justified; R = right justified
DEFINE m_hdr_show_selection_value.
  clear d_hdr_selection.
  concatenate &2 '%%' into d_hdr_selection separated by space.
  describe table &3 lines d_hdr_lines.
  if d_hdr_lines gt 1.
*-- More then 1 value for each selection criteria
    replace '%%' with 'Multiple Selection' into d_hdr_selection.
  elseif &3 is initial.
*-- Select all
    replace '%%' with 'All' into d_hdr_selection.
  else.
    describe field &3-low type d_hdr_types.
    write &3-low to d_hdr_low.
    write &3-high to d_hdr_high.
*-- Specific requirement
    if not ( d_hdr_types eq 'D' or d_hdr_types ne 'T' ).
*---- Don't delete leading zero for type DATE and TIME.
      shift d_hdr_low left deleting leading '0'.
      shift d_hdr_high left deleting leading '0'.
    endif.
    clear d_hdr_atext.
    if &3-sign = 'I'.
*---- Include range
      case &3-option.
*------ Equal
        when 'EQ'. replace '%%' with d_hdr_low into d_hdr_selection.
*------ Between
        when 'BT'.
          concatenate d_hdr_low 'to' d_hdr_high
                 into d_hdr_atext separated by space.
          replace '%%' with d_hdr_atext into d_hdr_selection.
*------ Others ( NE, GT, LT, GE, LE, LIKE )
        when others.
          concatenate &3-option d_hdr_low
               into d_hdr_atext separated by space.
          replace '%%' with d_hdr_atext into d_hdr_selection.
      endcase.
    else.
*---- Exclude range
      write: 'NOT'.
      case &3-option.
        when 'EQ'. replace '%%' with d_hdr_low into d_hdr_selection.
        when 'BT'.
          concatenate 'IN [' d_hdr_low 'to' d_hdr_high ']'
                 into d_hdr_atext separated by space.
          replace '%%' with d_hdr_atext into d_hdr_selection.
*------ Others ( NE, GT, LT, GE, LE, LIKE )
        when others.
          concatenate &3-option d_hdr_low
               into d_hdr_atext separated by space.
          replace '%%' with d_hdr_atext into d_hdr_selection.
      endcase.
    endif.
  endif.
  d_hdr_lngth = strlen( d_hdr_selection ).
  if &4 eq 'L' or &4 eq 'l'.
    write at &1(d_hdr_lngth) d_hdr_selection.
  else.
    d_hdr_rpos = &1 - d_hdr_lngth.
    write at d_hdr_rpos(d_hdr_lngth) d_hdr_selection.
  endif.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE


*&---------------------------------------------------------------------*
*&      Form  F_HDR_END
*&---------------------------------------------------------------------*
*       Output End-Of-Report text
*----------------------------------------------------------------------*
FORM f_hdr_end.
  SKIP.
  WRITE '         *** End of Report ***'(999)    " End of report
    COLOR COL_BACKGROUND.
ENDFORM.                    " F_HDR_END

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*  PERFORM f_execute(zabpxop_exec).
*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
*  write: d_hdr_title.
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18) VALUE 'Client:  XXX(YYY)',
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

*--- date
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_title USING ld_sysid fu_title ld_datum.
*  write: d_hdr_title.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title.
  DATA:
    ld_uzeit(5) VALUE 'hh:mm',
    ld_uname(21) VALUE 'User:    xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  PERFORM f_hdr_pad_title USING ld_uname fu_title ld_uzeit.
*  write: d_hdr_title.

ENDFORM.                    " F_HDR_LINE3


*&---------------------------------------------------------------------*
*&      Form  F_HDR_OPTIONS
*&---------------------------------------------------------------------*
*       Select options
*----------------------------------------------------------------------*
FORM f_hdr_options.
  DATA: BEGIN OF seltab OCCURS 5.
          INCLUDE STRUCTURE rsparams.
  DATA: END OF seltab.

  DATA: rpt LIKE sy-repid.
  rpt = sy-repid.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
       EXPORTING
            curr_report     = rpt
       TABLES
            selection_table = seltab
       EXCEPTIONS
            not_found       = 1
            no_report       = 2
            OTHERS          = 3.

*--- Delete unused selection options
  LOOP AT seltab.
    IF seltab-low = space.
      DELETE seltab.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'RS_LIST_SELECTION_TABLE'
       EXPORTING
            report        = rpt
            seltext       = 'X'
            newpage       = ' '
       TABLES
            sel_tab       = seltab
       EXCEPTIONS
            sel_tab_empty = 1
            OTHERS        = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_HEADER
*&---------------------------------------------------------------------*
FORM f_hdr_header USING fu_title.
  DATA: BEGIN OF lt_pool OCCURS 50.
          INCLUDE STRUCTURE textpool.
  DATA: END OF lt_pool.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING fu_title.
  READ TEXTPOOL sy-repid INTO lt_pool LANGUAGE sy-langu.
  READ TABLE lt_pool WITH KEY 'R'.
  PERFORM f_hdr_line2 USING lt_pool-entry.
  PERFORM f_hdr_line3 USING space.
  PERFORM f_hdr_uline.         " underline
ENDFORM.                    " F_HDR_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_HDR_VLINE
*&---------------------------------------------------------------------*
FORM f_hdr_vline.
  WRITE /01 sy-vline.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " F_HDR_VLINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_CALC_RUNTIME
*&---------------------------------------------------------------------*
FORM f_hdr_calc_runtime.
  DATA:
    ld_tot_runtime TYPE p DECIMALS 2,
    ld_hdr_rtime(5),
    ld_trunc TYPE i,
    ld_hh(2) TYPE n,
    ld_mm(2) TYPE n,
    ld_ss(2) TYPE n,
    ld_mi(2) TYPE n.

  SKIP.
  GET RUN TIME FIELD d_hdr_endrtime.
  ld_tot_runtime = ( d_hdr_endrtime - d_hdr_begrtime ) / 1000000.
  ld_trunc = trunc( ld_tot_runtime ).
  ld_hh = ld_trunc DIV 3600.
  ld_mm = ld_trunc DIV 60.
  ld_ss = ld_trunc MOD 60.
  ld_mi = ceil( ld_tot_runtime ).
  REPLACE 'HH' WITH ld_hh INTO d_hdr_rtime.
  REPLACE 'MM' WITH ld_mm INTO d_hdr_rtime.
  REPLACE 'SS' WITH ld_ss INTO d_hdr_rtime.
  REPLACE 'mm' WITH ld_mi INTO d_hdr_rtime.
ENDFORM.                    " F_HDR_CALC_RUNTIME

*&---------------------------------------------------------------------*
*&      Form  F_HDR_END_OF_REPORT
*&---------------------------------------------------------------------*
* Display 'End of Report' and run time program
FORM f_hdr_end_of_report.
  IF d_hdr_rtime CA sy-abcde.
    PERFORM f_hdr_calc_runtime.
  ENDIF.
  WRITE:/ '*** End of Report ( Run time =', d_hdr_rtime, ') ***'.
ENDFORM.                    " F_HDR_END_OF_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_HDR_START_REPORT
*&---------------------------------------------------------------------*
FORM f_hdr_start_report.
  GET RUN TIME FIELD d_hdr_begrtime.
ENDFORM.                    " F_HDR_START_REPORT
