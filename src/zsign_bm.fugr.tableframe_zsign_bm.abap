*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSIGN_BM
*   generation date: 20.08.2002 at 22:29:56 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSIGN_BM           .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
