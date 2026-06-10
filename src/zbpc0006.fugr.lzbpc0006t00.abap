*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBPC0006........................................*
DATA:  BEGIN OF STATUS_ZBPC0006                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBPC0006                      .
CONTROLS: TCTRL_ZBPC0006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZBPC0006                      .
TABLES: ZBPC0006                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
