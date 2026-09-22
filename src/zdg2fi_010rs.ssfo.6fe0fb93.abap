    WRITE s_printed-pswbt TO d_str_amount
    CURRENCY s_printed-pswsl.

  IF s_printed-shkzg EQ 'S'.
    CONCATENATE '-' d_str_amount into d_str_amount.
    d_pswbt = d_pswbt - s_printed-pswbt.
  ELSE.
    d_pswbt = d_pswbt + s_printed-pswbt.
  ENDIF.


















