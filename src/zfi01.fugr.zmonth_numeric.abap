FUNCTION ZMONTH_NUMERIC .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NAME) TYPE  C
*"  EXPORTING
*"     REFERENCE(MONTH) TYPE  NUMC2
*"----------------------------------------------------------------------

  CASE name.
    WHEN 'Januari'.
      MONTH = '01'.
    WHEN 'Februari'.
      MONTH = '02'.
    WHEN 'Maret'.
      MONTH = '03'.
    WHEN 'April'.
      MONTH = '04'.
    WHEN 'Mei'.
      MONTH = '05'.
    WHEN 'Juni'.
      MONTH = '06'.
    WHEN 'Juli'.
      MONTH = '07'.
    WHEN 'Agustus'.
      MONTH = '08'.
    WHEN 'September'.
      MONTH = '09'.
    WHEN 'Oktober'.
      MONTH = '10'.
    WHEN 'November'.
      MONTH = '11'.
    WHEN 'Desember'.
      MONTH = '12'.
  ENDCASE.

ENDFUNCTION.
