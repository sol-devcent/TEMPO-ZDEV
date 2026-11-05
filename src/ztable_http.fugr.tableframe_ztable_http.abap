*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTABLE_HTTP
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTABLE_HTTP        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
