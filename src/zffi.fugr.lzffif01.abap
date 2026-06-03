*----------------------------------------------------------------------*
***INCLUDE LZFFIF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  adjust_months
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ACT_DATE+4(2)  text
*      -->P_MON  text
*      -->P_TTL_YRS  text
*      -->P_ROUND  text
*----------------------------------------------------------------------*
FORM adjust_months USING act_month mon yrs round.

  IF mon > 11 OR
     mon < -11.
    yrs = mon / 12 - round.
    mon = mon - yrs * 12.
  ENDIF.

  mon = act_month + mon.

  IF mon <= 0.
    yrs = yrs - 1.
    mon = mon + 12.
  ELSE.
    IF mon > 12.
      yrs = yrs + 1.
      mon = mon - 12.
    ENDIF.
  ENDIF.

ENDFORM.                    " adjust_months
*&---------------------------------------------------------------------*
*&      Form  valid_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ACT_DATE  text
*      -->P_SIGN  text
*----------------------------------------------------------------------*
FORM valid_date USING    act_date
                         sign.

  DATA: test_date  TYPE d,
        corr_date  TYPE d.

  corr_date = act_date.

  DO.
    test_date = 1 + corr_date - 1.

    IF test_date = corr_date.
      EXIT.
    ENDIF.

    IF sign = '-'.
      corr_date+6(2) = corr_date+6(2) - 1.
      act_date = corr_date.
    ELSE.
      corr_date+6(2) = '01'.
      corr_date = corr_date + 32.
      corr_date+6(2) = '01'.
      act_date = corr_date - 1.
    ENDIF.
  ENDDO.

*  act_date = corr_date.

ENDFORM.                    " valid_date
