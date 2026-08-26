FUNCTION zffm_asset.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ANTS) LIKE  ANTS STRUCTURE  ANTS
*"     VALUE(I_DATBIS) LIKE  ANEP-BZDAT OPTIONAL
*"  EXPORTING
*"     VALUE(E_ANLCV) LIKE  ANLCV STRUCTURE  ANLCV
*"  TABLES
*"      T_ANEA STRUCTURE  ANEA
*"      T_ANEP STRUCTURE  ANEP
*"      T_ANFM STRUCTURE  ANFM
*"      T_ANLB STRUCTURE  ANLB
*"      T_ANLC STRUCTURE  ANLC
*"      T_ANLZ STRUCTURE  ANLZ
*"      T_ANLBZA STRUCTURE  ANLBZA OPTIONAL
*"----------------------------------------------------------------------
  DATA : i_anlc   TYPE anlc.

  CALL FUNCTION 'DEPR_RECALCULATE'
    EXPORTING
      i_ants                   = ants
      i_fehler                 = 'X'
      i_function               = 'N'
      i_cal_closed_fyears      = 'X'
      i_datbis                 = i_datbis
    TABLES
      t_anlb                   = t_anlb
      t_anlbza                 = t_anlbza
      t_anlc                   = t_anlc
      t_anlz                   = t_anlz
      t_anea                   = t_anea
      t_anep                   = t_anep
      t_anfm                   = t_anfm
    EXCEPTIONS
      answpruef_verletzt       = 1
      depr_not_posible         = 2
      minwert_verletzt         = 3
      normal_afa_verletzt      = 4
      period_false             = 5
      rbw_virt_afaber_verletzt = 6
      sonder_afa_verletzt      = 7
      OTHERS                   = 8.

  READ TABLE t_anlc INTO i_anlc INDEX 1.

  CALL FUNCTION 'FI_AA_VALUES_CALCULATE'
    EXPORTING
      i_anlc  = i_anlc
    IMPORTING
      e_anlcv = e_anlcv.
ENDFUNCTION.
