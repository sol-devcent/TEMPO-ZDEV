DATA: BEGIN OF lv_datum,
        year  TYPE char4,
        month TYPE char2,
        date  TYPE char2,
      END OF lv_datum,
      lv_name  TYPE char15.

DATA: lv_gsber LIKE zfgstt-gsber.

CASE sf_header-bukrs.
  WHEN '8020'.
    lv_gsber = '0200'.
  WHEN '8070'.
    lv_gsber = '0700'.
ENDCASE.

lv_datum = sf_header-budat.   "sy-datum.

CALL FUNCTION 'ZMONTH_NAME'
  EXPORTING
    month = lv_datum-month
  IMPORTING
    name  = lv_name.

CONCATENATE 'Jakarta,' lv_datum-date lv_name lv_datum-year
  INTO va_date SEPARATED BY space.

SELECT SINGLE petugas1 jabat1 graph
  INTO (va_name, va_titl, va_graph)
  FROM zfgstt
  WHERE gsber = lv_gsber
    AND zform = 'DN'.













