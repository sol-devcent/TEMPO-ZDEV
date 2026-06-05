FUNCTION z_ppn11.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PI_BUKRS) TYPE  RTAX1U38-BUKRS OPTIONAL
*"     REFERENCE(PI_MWSKZ) TYPE  RTAX1U38-MWSKZ OPTIONAL
*"     VALUE(PI_WRBTR) TYPE  NETWR_AK OPTIONAL
*"     VALUE(PI_CALTY) TYPE  CHAR5
*"     VALUE(PI_DATUM) TYPE  SY-DATUM OPTIONAL
*"     REFERENCE(PI_MASTX) TYPE  ABPER_RF OPTIONAL
*"  EXPORTING
*"     REFERENCE(PO_WRBTR) TYPE  NETWR_AK
*"     REFERENCE(PO_MWSKZ) TYPE  BAPIACTX09-TAX_CODE
*"     REFERENCE(PO_PPNTX) TYPE  CHAR10
*"     REFERENCE(PO_PPN) TYPE  CHAR2
*"----------------------------------------------------------------------

  DATA : ls_11    TYPE zproject,
         ls_12    TYPE zproject,
         lv_datum TYPE sy-datum.

  DATA : lr_datab TYPE RANGE OF datab,
         ls_datab LIKE LINE OF lr_datab.

  IF pi_mastx IS NOT INITIAL.
    CONCATENATE pi_mastx '01' INTO lv_datum.
  ELSE.
    lv_datum  = pi_datum.
  ENDIF.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_11
    FROM zproject
    WHERE name = 'PPN11'
      AND flag = 'X'.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_12
    FROM zproject
    WHERE name = 'PPN12'
      AND flag = 'X'.

  ls_datab-low    = ls_11-datab.
  ls_datab-high   = ls_12-datab.
  ls_datab-sign   = 'I'.
  ls_datab-option = 'BT'.
  APPEND ls_datab TO lr_datab.

  IF ls_11-datab IS INITIAL AND
    ls_12-datab IS INITIAL.
    PERFORM f_calc_old USING pi_calty ls_11-datab pi_wrbtr
                             ls_11-char1 ls_11-char2 ls_11-char3
                       CHANGING po_wrbtr po_mwskz po_ppntx po_ppn.
*  ELSEIF lv_datum >= ls_11-datab.
  ELSEIF lv_datum IN lr_datab.
    IF pi_bukrs IS NOT INITIAL AND
      pi_mwskz IS NOT INITIAL.
      PERFORM f_calc_with_fm USING pi_bukrs pi_mwskz pi_wrbtr
                             CHANGING po_wrbtr.
    ELSE.
      PERFORM f_calc_new11 USING pi_calty ls_11-datab pi_wrbtr
                                 ls_11-char1 ls_11-char2 ls_11-char3
                           CHANGING po_wrbtr po_mwskz po_ppntx po_ppn.
    ENDIF.
  ELSEIF lv_datum > ls_12-datab.
    IF pi_bukrs IS NOT INITIAL AND
      pi_mwskz IS NOT INITIAL.
      PERFORM f_calc_with_fm USING pi_bukrs pi_mwskz pi_wrbtr
                             CHANGING po_wrbtr.
    ELSE.
      PERFORM f_calc_new_12 USING pi_calty ls_12-datab pi_wrbtr
                                  ls_12-char1 ls_12-char2 ls_12-char3
                            CHANGING po_wrbtr po_mwskz po_ppntx po_ppn.
    ENDIF.
  ELSE.
    PERFORM f_calc_old USING pi_calty ls_11-datab pi_wrbtr
                             ls_11-char1 ls_11-char2 ls_11-char3
                       CHANGING po_wrbtr po_mwskz po_ppntx po_ppn.
  ENDIF.
ENDFUNCTION.
