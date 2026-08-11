DATA: ld_eket TYPE eket.

SELECT SINGLE * INTO ld_eket
  FROM eket
  WHERE ebeln = wa_dt-ebeln AND
        ebelp = wa_dt-ebelp.
IF sy-subrc = 0.
  wa_dt-eindt = ld_eket-eindt.
  wa_dt-charg = ld_eket-charg.
  wa_dt-lpein = ld_eket-lpein.
  wa_dt-menge = ld_eket-menge.
  wa_dt-banfn = ld_eket-banfn.
ENDIF.






















