FUNCTION ztdnsd_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(KDMAT) TYPE  KDMAT
*"  EXPORTING
*"     VALUE(MATNR) TYPE  MATNR
*"     VALUE(VCRNO) TYPE  ZVCRNO
*"     VALUE(VCRAMT) TYPE  WRBTR
*"     VALUE(WAERS) TYPE  WAERS
*"----------------------------------------------------------------------
"  TABLES: ztdnsddt010.
  DATA: l_kdmat(128).
  DATA: lwa_ztdnsddt010 TYPE ztdnsddt010.

  PERFORM f_get_encryption  USING    kdmat
                  CHANGING l_kdmat.
  CLEAR: matnr, vcrno, vcramt.
  SELECT SINGLE * INTO lwa_ztdnsddt010 FROM ztdnsddt010
    WHERE bukrs = '8380' AND vcr_encrp = l_kdmat. " AND vcrexp >= vbak-bstdk.

  IF sy-subrc EQ 0.
    IF lwa_ztdnsddt010-vcrsts NE 'USED' AND lwa_ztdnsddt010-flag IS INITIAL AND lwa_ztdnsddt010-vcrexp >= sy-datum.
      matnr  = lwa_ztdnsddt010-matnr.
      vcrno  = lwa_ztdnsddt010-vcrno.
      vcramt = lwa_ztdnsddt010-vcramt.
      waers  = 'IDR'.
    else.
      clear:   vcrno, matnr, vcramt.
    ENDIF.
  ENDIF.
***  CONDENSE kdmat.
***  IF kdmat = '1234567890' and matnr is INITIAL.
***    matnr  = 'VCR010'.
***    vcrno  = 'CCN001'.
***    vcramt = '100000'.
***    waers  = 'IDR'.
***  ENDIF.
ENDFUNCTION.
