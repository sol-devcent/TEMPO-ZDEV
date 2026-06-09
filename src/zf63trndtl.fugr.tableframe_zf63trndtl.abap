*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZF63TRNDTL
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZF63TRNDTL         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
