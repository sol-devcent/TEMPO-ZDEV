*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTR_RATE_MST....................................*
DATA:  BEGIN OF STATUS_ZTR_RATE_MST                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTR_RATE_MST                  .
CONTROLS: TCTRL_ZTR_RATE_MST
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTR_RATE_MST                  .
TABLES: ZTR_RATE_MST                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
