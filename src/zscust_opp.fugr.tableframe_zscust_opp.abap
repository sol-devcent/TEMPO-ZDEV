*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSCUST_OPP
*   generation date: 12.05.2006 at 15:32:19 by user TDS_DEV01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSCUST_OPP         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
