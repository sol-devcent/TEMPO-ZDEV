*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFNREXCLUDE
*   generation date: 05.03.2007 at 11:55:56 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFNREXCLUDE        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
