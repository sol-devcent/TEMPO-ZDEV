DATA: ld_len  TYPE i,
      ld_kurrf(20),
      ld_dig01(3).
DATA: str1 TYPE string,
      str2 TYPE string.
DATA: l_kurrf TYPE p DECIMALS 2.
break bcdik.
IF t_header-waerk NE 'IDR'.
  l_kurrf   = t_header-kurrf * 1000.
  ld_kurrf  = l_kurrf.
  SHIFT ld_kurrf LEFT DELETING LEADING space.
  SPLIT ld_kurrf AT '.' INTO: str1 str2.
  ld_len = STRLEN( str1 ).
  ld_dig01 = ld_len - 3.
  CONCATENATE str1(ld_dig01) '.' str1+ld_dig01(3) ',' str2 INTO d_kurrf.
ENDIF.



























