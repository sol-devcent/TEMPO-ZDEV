*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT009........................................*
DATA:  BEGIN OF STATUS_ZFIDT009                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT009                      .
CONTROLS: TCTRL_ZFIDT009
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT009                      .
TABLES: ZFIDT009                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
