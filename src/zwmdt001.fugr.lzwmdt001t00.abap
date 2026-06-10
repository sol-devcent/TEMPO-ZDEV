*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT001........................................*
DATA:  BEGIN OF STATUS_ZWMDT001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT001                      .
CONTROLS: TCTRL_ZWMDT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT001                      .
TABLES: ZWMDT001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
