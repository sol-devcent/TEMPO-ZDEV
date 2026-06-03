*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSPRLSOM
*   generation date: 15.07.2005 at 10:59:27 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSPRLSOM           .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
