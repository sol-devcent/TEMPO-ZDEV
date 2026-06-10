*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT007........................................*
DATA:  BEGIN OF STATUS_ZWMDT007                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT007                      .
CONTROLS: TCTRL_ZWMDT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT007                      .
TABLES: ZWMDT007                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
