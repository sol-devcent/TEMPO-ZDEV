*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZKOMERNR
*   generation date: 26.12.2006 at 15:50:14 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZKOMERNR           .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
