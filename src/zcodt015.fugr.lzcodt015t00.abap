*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT015........................................*
DATA:  BEGIN OF STATUS_ZCODT015                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT015                      .
CONTROLS: TCTRL_ZCODT015
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT015                      .
TABLES: ZCODT015                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
