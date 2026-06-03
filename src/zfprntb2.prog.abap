*----------------------------------------------------------------------*
*   INCLUDE ZFPRNTB2                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  print_b2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_b2.
    select single * from t001 where bukrs = PA_bukrs.
    if sy-subrc <> 0.
       clear t001.
    endif.
    select single * from zftax where bukrs = PA_bukrs
                                 and gsber = PA_gsber.
    if sy-subrc <> 0.
       clear zftax.
    endif.

  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  concatenate pa_gjahr pa_monat '01' into ta_date-low.
  call function 'LAST_DAY_OF_MONTHS'
       exporting
          day_in = ta_date-low
       importing
          LAST_DAY_OF_MONTH = ta_date-high.
  append ta_date.

  va_thn = pa_gjahr.
  case pa_monat.
    when '01' or '1 ' or ' 1'.
       va_prd = 'Januari'.
    when '02' or '2 ' or ' 2'.
       va_prd = 'Pebruari'.
    when '03' or '3 ' or ' 3'.
       va_prd = 'Maret'.
    when '04' or '4 ' or ' 4'.
       va_prd = 'April'.
    when '05' or '5 ' or ' 5'.
       va_prd = 'Mei'.
    when '06' or '6 ' or ' 6'.
       va_prd = 'Juni'.
    when '07' or '7 ' or ' 7'.
       va_prd = 'Juli'.
    when '08' or '8 ' or ' 8'.
       va_prd = 'Agustus'.
    when '09' or '9 ' or ' 9'.
       va_prd = 'September'.
    when '10'.
       va_prd = 'Oktober'.
    when '11'.
       va_prd = 'Nopember'.
    when '12'.
       va_prd = 'Desember'.
  endcase.


  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZF_B2_FORM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER4'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LINE1'
      WINDOW = 'LINE'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'NIHIL'
      WINDOW = 'MAIN'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'AKHIR1'
      WINDOW = 'AKHIR1'
    EXCEPTIONS
     OTHERS = 1.

 CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " print_b2
