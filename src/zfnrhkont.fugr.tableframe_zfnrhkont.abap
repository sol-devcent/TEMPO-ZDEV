*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFNRHKONT
*   generation date: 22.02.2007 at 15:42:18 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFNRHKONT          .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
