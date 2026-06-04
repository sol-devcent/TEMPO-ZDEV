*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTAX
*   generation date: 13.09.2002 at 17:45:52 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTAX               .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
