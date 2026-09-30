FUNCTION zwmsfm007.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_LGNUM) TYPE  LTAK-LGNUM OPTIONAL
*"     VALUE(PI_LZNUM) TYPE  LTAK-LZNUM OPTIONAL
*"     VALUE(PI_LENGTH) TYPE  INT4 OPTIONAL
*"  TABLES
*"      PT_PICK STRUCTURE  ZWMSST013
*"----------------------------------------------------------------------
  IF pi_length = 15.
    PERFORM f_process_grouping TABLES pt_pick
                               USING pi_lgnum pi_lznum.
  ENDIF.




ENDFUNCTION.
