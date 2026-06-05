*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT012........................................*
DATA:  BEGIN OF STATUS_ZCODT012                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT012                      .
CONTROLS: TCTRL_ZCODT012
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT012                      .
TABLES: ZCODT012                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
