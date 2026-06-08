*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZNRMAP
*   generation date: 06.02.2007 at 10:45:01 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZNRMAP             .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
