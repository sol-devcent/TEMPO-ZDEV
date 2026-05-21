*----------------------------------------------------------------------*
*   INCLUDE ZIBM_HEADER                                                *
*----------------------------------------------------------------------*

data:
  d_hdr_rpt_lines value 'X',
  d_hdr_selection(50),
  d_hdr_rpos type i,
  d_hdr_lines type i,
  d_hdr_types,
  d_hdr_intsf,   "Flag for intensified
  d_hdr_low(30),
  d_hdr_high(30),
  d_hdr_atext(80),
  d_hdr_lngth type i,
  d_hdr_title(999),           " Report title with padding
  d_hdr_text1(999),           " User text 1
  d_hdr_text2(999),           " User text 2
  d_hdr_text3(999).           " User text 3

data: d_hdr_begrtime type i,
      d_hdr_endrtime type i,
      d_hdr_rtime(15) value 'HH:MM:SS,mm'.

*&---------------------------------------------------------------------*
*&      Macro  m_hdr_show_selection_value
*&---------------------------------------------------------------------*
* Display value of SELECT-OPTIONS
* &1 => cursor position
* &2 => decription
* &3 => internal table from selection screen
* &4 => L = left justified; R = right justified
define m_hdr_show_selection_value.
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
        when 'BT'. concatenate d_hdr_low 'to' d_hdr_high
                          into d_hdr_atext separated by space.
                   replace '%%' with d_hdr_atext into d_hdr_selection.
*------ Others ( NE, GT, LT, GE, LE, LIKE )
        when others. concatenate &3-option d_hdr_low
                          into d_hdr_atext separated by space.
                   replace '%%' with d_hdr_atext into d_hdr_selection.
      endcase.
    else.
*---- Exclude range
      write: 'NOT'.
      case &3-option.
        when 'EQ'. replace '%%' with d_hdr_low into d_hdr_selection.
        when 'BT'. concatenate 'IN [' d_hdr_low 'to' d_hdr_high ']'
                          into d_hdr_atext separated by space.
                   replace '%%' with d_hdr_atext into d_hdr_selection.
*------ Others ( NE, GT, LT, GE, LE, LIKE )
        when others. concatenate &3-option d_hdr_low
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
end-of-definition.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
form f_hdr_pad_title using v_left_text v_middle_text v_right_text.

data:
    page_width type i,       " Width of page
    middle_length type i,    " Length of title text
    left_length type i,      " Length of left text
    right_length type i,     " Length of right text
    left_start type i,       " Position on line for start of left tex
    middle_start type i,     " Position on line for start of middl tex
    right_start type i.      " Position on line for start of right tex

*--- Start with a blank title
  clear d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  compute middle_length = strlen( v_middle_text ).
  compute left_length = strlen( v_left_text ).
  compute right_length = strlen( v_right_text ).

  compute middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  if d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  endif.
  right_start = sy-linsz - left_start - right_length - 1.
  write:/ sy-vline.
*--- Insert texts
  if left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    write at (left_length) v_left_text.
  endif.
  if middle_length <> 0.
    write at middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  endif.
  if right_length <> 0.
    write at right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  endif.
  write at sy-linsz sy-vline.
endform.                    " F_HDR_PAD_TITLE


*&---------------------------------------------------------------------*
*&      Form  F_HDR_END
*&---------------------------------------------------------------------*
*       Output End-Of-Report text
*----------------------------------------------------------------------*
form f_hdr_end.
  skip.
  write '         *** End of Report ***'(999)    " End of report
    color col_background.
endform.                    " F_HDR_END

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
form f_hdr_uline.
  if d_hdr_rpt_lines = 'X'.
    uline.
  endif.
endform.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
form f_hdr_line1 using fu_company.
data:
  page_number(10) value 'Page: nnnn',
  progname(42) value 'Program: xx',
  ld_progname(20),
  page(4).

*--- Page number
  page = sy-pagno.
  replace 'nnnn' with page into page_number.
  if sy-cprog eq sy-repid.
    replace 'xx' with sy-repid into progname.
  else.
   concatenate sy-repid '(' sy-cprog ')' into ld_progname.
   replace 'xx' with ld_progname into progname.
  endif.

*--- Output line
  perform f_hdr_pad_title using progname fu_company page_number.
endform.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
form f_hdr_line2 using fu_title.
data:
  ld_sysid(18) value 'Client:  XXX(YYY)',
  ld_datum(10).

*--- system info
  replace 'XXX' with sy-sysid(3) into ld_sysid.
  replace 'YYY' with sy-mandt into ld_sysid.

*--- date
  write sy-datum to ld_datum.

*--- output line
  perform f_hdr_pad_title using ld_sysid fu_title ld_datum.
endform.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
form f_hdr_line3 using fu_title.
data:
  ld_uzeit(5) value 'hh:mm',
  ld_uname(21) value 'User:    xx'.

*--- time
  replace 'hh' with sy-uzeit(2) into ld_uzeit.     " hour
  replace 'mm' with sy-uzeit+2(2) into ld_uzeit.   " minute

*--- user
  replace 'xx' with sy-uname into ld_uname.

*--- output line
  perform f_hdr_pad_title using ld_uname fu_title ld_uzeit.

endform.                    " F_HDR_LINE3


*&---------------------------------------------------------------------*
*&      Form  F_HDR_OPTIONS
*&---------------------------------------------------------------------*
*       Select options
*----------------------------------------------------------------------*
form f_hdr_options.
  data: begin of seltab occurs 5.
    include structure rsparams.
  data: end of seltab.

  data: rpt like sy-repid.
  rpt = sy-repid.

  call function 'RS_REFRESH_FROM_SELECTOPTIONS'
      exporting
           curr_report     = rpt
      tables
           selection_table = seltab
      exceptions
           not_found       = 1
           no_report       = 2
           others          = 3.

*--- Delete unused selection options
  loop at seltab.
    if seltab-low = space.
      delete seltab index sy-tabix.
    endif.
  endloop.

  call function 'RS_LIST_SELECTION_TABLE'
      exporting
           report        = rpt
           seltext       = 'X'
           newpage       = ' '
      tables
           sel_tab       = seltab
      exceptions
           sel_tab_empty = 1
          others        = 2.

endform.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_HEADER
*&---------------------------------------------------------------------*
form f_hdr_header using fu_title.
data: begin of lt_pool occurs 50.
      include structure textpool.
data: end of lt_pool.

  perform f_hdr_uline.
  perform f_hdr_line1 using fu_title.
  read textpool sy-repid into lt_pool language sy-langu.
  read table lt_pool with key 'R'.
  perform f_hdr_line2 using lt_pool-entry.
  perform f_hdr_line3 using space.
  perform f_hdr_uline.         " underline
endform.                    " F_HDR_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_HDR_VLINE
*&---------------------------------------------------------------------*
form f_hdr_vline.
  write /01 sy-vline.
  write at sy-linsz sy-vline.
endform.                    " F_HDR_VLINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_CALC_RUNTIME
*&---------------------------------------------------------------------*
form f_hdr_calc_runtime.
data:
  ld_tot_runtime type p decimals 2,
  ld_hdr_rtime(5),
  ld_trunc type i,
  ld_hh(2) type n,
  ld_mm(2) type n,
  ld_ss(2) type n,
  ld_mi(2) type n.

  skip.
  get run time field d_hdr_endrtime.
  ld_tot_runtime = ( d_hdr_endrtime - d_hdr_begrtime ) / 1000000.
  ld_trunc = trunc( ld_tot_runtime ).
  ld_hh = ld_trunc div 3600.
  ld_mm = ld_trunc div 60.
  ld_ss = ld_trunc mod 60.
  ld_mi = ceil( ld_tot_runtime ).
  replace 'HH' with ld_hh into d_hdr_rtime.
  replace 'MM' with ld_mm into d_hdr_rtime.
  replace 'SS' with ld_ss into d_hdr_rtime.
  replace 'mm' with ld_mi into d_hdr_rtime.
endform.                    " F_HDR_CALC_RUNTIME

*&---------------------------------------------------------------------*
*&      Form  F_HDR_END_OF_REPORT
*&---------------------------------------------------------------------*
* Display 'End of Report' and run time program
form f_hdr_end_of_report.
  if d_hdr_rtime ca sy-abcde.
    perform f_hdr_calc_runtime.
  endif.
  write:/ '*** End of Report ( Run time =', d_hdr_rtime, ') ***'.
endform.                    " F_HDR_END_OF_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_HDR_START_REPORT
*&---------------------------------------------------------------------*
form f_hdr_start_report.
  get run time field d_hdr_begrtime.
endform.                    " F_HDR_START_REPORT
