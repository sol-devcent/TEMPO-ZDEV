FUNCTION ZPSSV_TEXT_INTO_FIELD_CURRENCY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_AMOUNT)
*"     REFERENCE(I_CURRENCY)
*"  EXPORTING
*"     REFERENCE(E_AMOUNT)
*"  EXCEPTIONS
*"      WRONG_AMOUNT
*"      WRONG_CURRENCY
*"      WRONG_DECIMAL
*"----------------------------------------------------------------------

data: amount_tmp(255)  type c,
*      amount_tmp_p(7)  type p decimals 3, "like prps-usr06,
      amount_tmp_p(9)  type p decimals 3, "like prps-usr06,
      currency_tmp(5)  type c,
      dec_tmp(13)      type p decimals 3,
      amount_frac      type p decimals 3,
      amount_trunc     type i,
      amount_repl(255) type c,
      currdec_tmp      like tcurx-currdec.

data: lw_tcurc LIKE tcurc,
      lw_tcurx LIKE tcurx.

  move i_amount to amount_tmp.
  move i_currency to currency_tmp.

  if amount_tmp cn '1234567890,. '.
    if sy-subrc = 0 and
       sy-fdpos <> 0.
      message e406(F4) with amount_tmp. " raising wrong_amount.
    endif.
  endif.
*Check the decimals caracter in user profile
*  select single * from usr01 where bname = sy-uname.
*  if sy-subrc ne 0.
*    raise wrong_amount.
*  endif.
  amount_repl = amount_tmp.
*  case usr01-dcpfm.
*    when ' '.
  replace ',' with '.' into amount_repl.
  if sy-subrc = 0.
    amount_repl = amount_tmp.
    replace '.' with ' ' into amount_repl.
    replace ',' with '.' into amount_repl.
  endif.
*    when 'X'.
*      replace ',' with ' ' into amount_repl.
*    when 'Y'.
*      replace ',' with ' ' into amount_repl.
*    when others.
*      raise wrong_amount.
*  endcase.
  condense amount_repl no-gaps.
  amount_tmp = amount_repl.
*Check the currency key
  if not currency_tmp is initial.
    translate currency_tmp to upper case.   "#EC SYNTCHAR
    select single * INTO lw_tcurc from tcurc where waers = currency_tmp.
    if sy-subrc ne 0.
      message e352(F4) with currency_tmp. " raising wrong_currency.
    endif.
*Get the currency decimals
    select single * INTO lw_tcurx from tcurx where currkey = currency_tmp.
    if sy-subrc = 0.
      currdec_tmp = lw_tcurx-currdec.
    else.
      currdec_tmp = 2.
    endif.
  else.
    currdec_tmp = 2.
  endif.

*Check i_amount decimals
  move amount_tmp to amount_tmp_p.
  case currdec_tmp.
    when 0.
      dec_tmp = amount_tmp_p.
    when 1.
      dec_tmp = amount_tmp_p * 10.
    when 2.
      dec_tmp = amount_tmp_p * 100.
    when 3.
      dec_tmp = amount_tmp_p * 1000.
    when others.
      message e424(F5). " raising wrong_dezimal.
  endcase.
  amount_frac = frac( dec_tmp ).
  if amount_frac ne 0.
    message e009(F5) with amount_tmp. " raising wrong_amount.
  endif.
*Convert input i_amount into output e_amount
  case currdec_tmp.
    when 0.
      amount_tmp_p = amount_tmp_p / 1000.
    when 1.
      amount_tmp_p = amount_tmp_p / 100.
    when 2.
      amount_tmp_p = amount_tmp_p / 10.
    when 3.
      amount_tmp_p = amount_tmp_p.
    when others.
  endcase.

*  amount_trunc = trunc( amount_tmp_p ).
*  move amount_trunc to amount_tmp.
  move amount_tmp_p to amount_tmp.
  condense amount_tmp.
  e_amount = amount_tmp.

ENDFUNCTION.
