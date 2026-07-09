*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT017........................................*
DATA:  BEGIN OF STATUS_ZCODT017                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT017                      .
CONTROLS: TCTRL_ZCODT017
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT017                      .
TABLES: ZCODT017                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
