CLEAR gv_maktx.

ADD 1 TO gv_count.

CASE gv_count.
  WHEN 1.
    gv_maktx = gs_detail-maktx3.
  WHEN 2.
    gv_maktx = gs_detail-maktx4.
  WHEN 3.
    gv_maktx = gs_detail-maktx5.
ENDCASE.




















