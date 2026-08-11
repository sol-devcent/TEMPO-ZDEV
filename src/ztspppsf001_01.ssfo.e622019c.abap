DATA: lv_percen TYPE zpercen.

CLEAR gv_percen.
lv_percen = GS_DETAIL-RUSAK / GS_DETAIL-ERFMG * 100.
WRITE lv_percen TO gv_percen.



















