*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMGRPBWART
*   generation date: 27.03.2003 at 15:59:57 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMGRPBWART         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
