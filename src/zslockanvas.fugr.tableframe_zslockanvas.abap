*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSLOCKANVAS
*   generation date: 23.07.2002 at 11:01:13 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSLOCKANVAS        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
