FUNCTION ZMONTH_NAME.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(MONTH) TYPE  C
*"  EXPORTING
*"     REFERENCE(NAME) TYPE  C
*"----------------------------------------------------------------------
  case month.
    when '01' or '1 ' or ' 1'.
       name = 'Januari'.
    when '02' or '2 ' or ' 2'.
       name = 'Februari'.
    when '03' or '3 ' or ' 3'.
       name = 'Maret'.
    when '04' or '4 ' or ' 4'.
       name = 'April'.
    when '05' or '5 ' or ' 5'.
       name = 'Mei'.
    when '06' or '6 ' or ' 6'.
       name = 'Juni'.
    when '07' or '7 ' or ' 7'.
       name = 'Juli'.
    when '08' or '8 ' or ' 8'.
       name = 'Agustus'.
    when '09' or '9 ' or ' 9'.
       name = 'September'.
    when '10'.
       name = 'Oktober'.
    when '11'.
       name = 'November'.
    when '12'.
       name = 'Desember'.
  endcase.

ENDFUNCTION.
