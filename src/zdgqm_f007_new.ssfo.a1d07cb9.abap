DATA: lv_menge  TYPE  char20,
      lv_anzgeb TYPE  char20,
      lv_rkmng  TYPE  char20,
      lv_reject TYPE  char20.

IF header-grdat IS INITIAL.
  gv_grdat = ' - '.
ELSE.
  WRITE header-grdat TO gv_grdat.
ENDIF.

WRITE header-hsdat TO gv_hsdat.
WRITE header-vfdat TO gv_vfdat.
WRITE header-menge TO lv_menge DECIMALS 3.
WRITE header-anzgeb TO lv_anzgeb DECIMALS 0.
WRITE header-rkmng TO lv_rkmng DECIMALS 3.
WRITE header-reject TO lv_reject DECIMALS 0.

CONDENSE: lv_menge,lv_anzgeb,lv_rkmng,lv_reject.

IF header-menge IS INITIAL.
  gv_grqty = ' - '.
ELSEIF header-gebeh IS INITIAL.
  CONCATENATE lv_menge header-meins
              INTO gv_grqty SEPARATED BY space.
ELSE.
  CONCATENATE lv_menge header-meins '('
              lv_anzgeb header-gebeh ')'
              INTO gv_grqty SEPARATED BY space.
ENDIF.

IF header-qmart = 'T3'.
  CONCATENATE lv_rkmng header-mgein
              INTO gv_rjqty SEPARATED BY space.
ELSEIF header-gebeh IS INITIAL.
  CONCATENATE lv_rkmng header-mgein
              INTO gv_rjqty SEPARATED BY space.
ELSE.
  IF header-bzmng = header-rkmng.
    CONCATENATE lv_rkmng header-mgein '('
                lv_anzgeb header-gebeh ')'
                INTO gv_rjqty SEPARATED BY space.
  ELSE.
    CONCATENATE lv_rkmng header-mgein '('
                lv_reject header-gebeh ')'
                INTO gv_rjqty SEPARATED BY space.
  ENDIF.
ENDIF.




