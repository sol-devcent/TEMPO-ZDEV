*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMT0001........................................*
DATA:  BEGIN OF STATUS_ZMMT0001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMT0001                      .
CONTROLS: TCTRL_ZMMT0001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMT0001                      .
TABLES: ZMMT0001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
