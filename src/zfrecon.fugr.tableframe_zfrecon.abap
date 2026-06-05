*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFRECON
*   generation date: 19.12.2002 at 10:24:47 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFRECON            .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
