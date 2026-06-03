FUNCTION z_calc_date.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(DATE) LIKE  BKPF-BLDAT
*"     REFERENCE(DAYS) LIKE  BSEG-DTWS1
*"     REFERENCE(MONTHS) LIKE  BSEG-DTWS2
*"     REFERENCE(SIGN) LIKE  BSEG-XNEGP DEFAULT '+'
*"     REFERENCE(YEARS) LIKE  BSEG-DTWS3
*"  EXPORTING
*"     VALUE(CALC_DATE) TYPE  BKPF-BLDAT
*"----------------------------------------------------------------------

  DATA: act_date   TYPE d,
        dys        TYPE p,
        mon        TYPE p,
        yrs        TYPE p,
        ttl_yrs    TYPE p
                   VALUE 0,
        round      TYPE p
                   DECIMALS 2
                   VALUE '0.50'.

  act_date = date.
* LOW-DATE = 01/01/1800, HIGH-DATE = 31/12/9999 - Core assumes this
  IF ( date <> '99991231' OR
        sign = '-' ) AND
      ( date <> '18000101' OR
        sign <> '-' ).
    IF sign = '-'.
      dys = - days.
      mon = - months.
      yrs = - years.
      round = - round.
    ELSE.
      dys = days.
      mon = months.
      yrs = years.
    ENDIF.

    IF mon <> 0.
      PERFORM adjust_months USING act_date+4(2)
                                  mon ttl_yrs round.
      UNPACK mon TO act_date+4(2).
    ENDIF.

    ttl_yrs = yrs + ttl_yrs.
    act_date(4) = act_date(4) + ttl_yrs.

    PERFORM valid_date USING act_date
                             sign.

    act_date = act_date + dys.

  ENDIF.

  calc_date = act_date.

ENDFUNCTION.
