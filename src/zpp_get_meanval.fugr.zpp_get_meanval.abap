FUNCTION zpp_get_meanval.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PI_WERKS) TYPE  WERKS_D
*"     REFERENCE(PI_MATNR) TYPE  MATNR
*"     REFERENCE(PI_CHARG) TYPE  CHARG_D
*"  EXPORTING
*"     REFERENCE(PE_MEANVAL) TYPE  QMEAN_VAL
*"----------------------------------------------------------------------
  DATA: lv_qty      TYPE resb-enmng,
        lv_meanval  TYPE bapi2045d2-mean_value,
        lv_meanval2 TYPE bapi2045d2-mean_value,
        lv_text     TYPE bapi2045l2-txt_oper,
        lv_inspoper TYPE bapi2045l2-inspoper.

  SELECT SINGLE * INTO @DATA(ls_006)
    FROM ztspppdt006 WHERE werks = @pi_werks
                       AND matnr = @pi_matnr
                       AND excty = 'P'.

  lv_text     = 'Berat Rata – Rata'.
  lv_inspoper = '9999'.

  PERFORM f_change_inspoper(ztsppp_e001) USING pi_matnr pi_charg pi_werks
                                         CHANGING lv_text lv_inspoper.

  CALL FUNCTION 'ZQMMATNR_FACTOR'
    EXPORTING
      i_matnr      = pi_matnr
      i_charg      = pi_charg
      i_werks      = pi_werks
      i_text       = lv_text
      i_inspoper   = lv_inspoper
    IMPORTING
      e_mean_value = lv_meanval.

  TRANSLATE lv_meanval USING '. '.
  TRANSLATE lv_meanval USING ',.'.
  CONDENSE lv_meanval.
  IF lv_meanval IS INITIAL.
  ELSE.
    lv_qty = lv_meanval.
    WRITE lv_qty TO lv_meanval2 DECIMALS 2.
    TRANSLATE lv_meanval2 USING '. '.
    TRANSLATE lv_meanval2 USING ',.'.
    CONDENSE lv_meanval2.
    pe_meanval = lv_meanval2.
  ENDIF.

ENDFUNCTION.
