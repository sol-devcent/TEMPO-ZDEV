DATA: lv_percen TYPE zpercen,
      lv_qtybls LIKE gs_header-qtybls,
      lv_qtytab LIKE gs_header-qtytab,
      ls_ztspppdt0011 LIKE ztspppdt0011.

SELECT SINGLE * INTO ls_ztspppdt0011
  FROM ztspppdt0011 WHERE matnr = gs_header-matnr.

IF sy-subrc = 0.
  lv_qtybls = ls_ztspppdt0011-qtybls.
  lv_qtytab = ls_ztspppdt0011-qtytab.
ELSE.
  lv_qtybls = gs_header-qtybls.
  lv_qtytab = gs_header-qtytab.
ENDIF.

gv_uombls = gs_header-uombls.
gv_uomtab = gs_header-uomtab.

WRITE gs_header-vfdat TO gv_vfdat.
WRITE lv_qtybls TO gv_qtybls UNIT gs_header-meins.
WRITE lv_qtytab TO gv_qtytab UNIT gs_header-meins.
WRITE gs_header-qtynyata TO gv_qtynyata UNIT gs_header-meins.
CLEAR gv_percen.
lv_percen = gs_header-qtynyata / lv_qtytab * 100.
WRITE lv_percen TO gv_percen.

break bcdik.

IF gs_header-qtyconv1 IS INITIAL.
  CLEAR gv_car.
ELSE.
  WRITE gs_header-qtyconv1 TO gv_car UNIT gs_header-uomconv1.
ENDIF.

WRITE gs_header-qtyconv2 TO gv_sw UNIT gs_header-uomconv2.

*DATA: lv_car1  TYPE int4,   "Pembulatan hasil bagi
*      lv_car2  TYPE int4,   "Sisa hasil bagi
*      lv_sw1   TYPE int4,
*      lv_sw2   TYPE int4,
*      lt_marm  TYPE TABLE OF marm WITH HEADER LINE.
*
*SELECT matnr meinh umren umrez
*  INTO CORRESPONDING FIELDS OF TABLE lt_marm
*  FROM marm WHERE matnr = gs_header-matnr.
*
*IF sy-subrc = 0.
*  CLEAR lt_marm.
*  READ TABLE lt_marm WITH KEY matnr = gs_header-matnr
*                              meinh = 'KAR'.
*  lv_car1 = gs_header-qtynyata DIV lt_marm-umrez.
*  lv_car2 = gs_header-qtynyata MOD lt_marm-umrez.
*  WRITE lv_car1 TO gv_car.
*
*  CLEAR lt_marm.
*  READ TABLE lt_marm WITH KEY matnr = gs_header-matnr
*                              meinh = 'SW'.
*  IF sy-subrc = 0.
*    lv_sw1 = lv_car2 DIV lt_marm-umrez.
*    lv_sw2 = lv_car2 MOD lt_marm-umrez.
*  ELSE.
*    lv_sw1 = 0.
*    lv_sw2 = lv_car2.
*  ENDIF.
*  WRITE lv_sw1 TO gv_sw.
*  WRITE lv_sw2 TO gv_sisa.
*ENDIF.
