DATA lv_length TYPE i.

lv_length = STRLEN( gs_header-sk_pbf ).
IF lv_length GT 36.
  gv_sk_pbf1 = gs_header-sk_pbf(36).
  gv_sk_pbf2 = gs_header-sk_pbf+36(64).
ELSE.
  gv_sk_pbf1 = gs_header-sk_pbf.
ENDIF.





















