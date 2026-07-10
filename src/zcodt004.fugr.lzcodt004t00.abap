*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT004........................................*
DATA:  BEGIN OF STATUS_ZCODT004                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT004                      .
CONTROLS: TCTRL_ZCODT004
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT004                      .
TABLES: ZCODT004                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
