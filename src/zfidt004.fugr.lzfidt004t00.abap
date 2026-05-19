*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT004........................................*
DATA:  BEGIN OF STATUS_ZFIDT004                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT004                      .
CONTROLS: TCTRL_ZFIDT004
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT004                      .
TABLES: ZFIDT004                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
