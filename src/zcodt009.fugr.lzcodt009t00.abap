*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT009........................................*
DATA:  BEGIN OF STATUS_ZCODT009                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT009                      .
CONTROLS: TCTRL_ZCODT009
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT009                      .
TABLES: ZCODT009                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
