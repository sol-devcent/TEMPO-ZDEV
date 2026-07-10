*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT001........................................*
DATA:  BEGIN OF STATUS_ZCODT001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT001                      .
CONTROLS: TCTRL_ZCODT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT001                      .
TABLES: ZCODT001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
