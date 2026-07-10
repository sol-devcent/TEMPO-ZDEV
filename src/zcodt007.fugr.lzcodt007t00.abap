*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT007........................................*
DATA:  BEGIN OF STATUS_ZCODT007                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT007                      .
CONTROLS: TCTRL_ZCODT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT007                      .
TABLES: ZCODT007                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
