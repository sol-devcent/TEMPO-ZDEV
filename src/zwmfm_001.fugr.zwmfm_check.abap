FUNCTION zwmfm_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_MATNR) TYPE  MARA-MATNR OPTIONAL
*"     VALUE(PI_LGNUM) TYPE  LTAK-LGNUM OPTIONAL
*"     VALUE(PI_MENGE) TYPE  MSEG-MENGE OPTIONAL
*"     VALUE(PI_LGTYP) TYPE  LAGP-LGTYP OPTIONAL
*"     VALUE(PI_LGPLA) TYPE  LAGP-LGPLA OPTIONAL
*"     VALUE(PI_MEINS) TYPE  MSEG-MEINS OPTIONAL
*"  EXPORTING
*"     VALUE(PE_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------
  DATA : lv_mkapv     TYPE mlgn-mkapv,
         lv_bezme     TYPE mlgn-bezme,
         lv_menge     TYPE mseg-menge,
         lv_menga     TYPE mseg-menge,
         lv_rkapv     TYPE lagp-rkapv.

  SELECT SINGLE mkapv bezme
    FROM mlgn
    INTO (lv_mkapv, lv_bezme)
    WHERE matnr = pi_matnr
      AND lgnum = pi_lgnum.

  SELECT SINGLE rkapv
    FROM lagp
    INTO lv_rkapv
    WHERE lgnum = pi_lgnum
      AND lgtyp = pi_lgtyp
      AND lgpla = pi_lgpla.

  lv_menge = pi_menge * lv_mkapv.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = lv_menge
      matnr                = pi_matnr
      meinh                = lv_bezme
      meins                = pi_meins
    IMPORTING
      output               = lv_menga
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

  IF lv_menga > lv_rkapv.
    pe_subrc = 1.
  ENDIF.
ENDFUNCTION.
