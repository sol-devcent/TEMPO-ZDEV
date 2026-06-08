*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTR_REVENUE_MST.................................*
DATA:  BEGIN OF STATUS_ZTR_REVENUE_MST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTR_REVENUE_MST               .
CONTROLS: TCTRL_ZTR_REVENUE_MST
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTR_REVENUE_MST               .
TABLES: ZTR_REVENUE_MST                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
