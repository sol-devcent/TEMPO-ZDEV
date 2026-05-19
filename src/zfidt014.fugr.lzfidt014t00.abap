*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT014........................................*
DATA:  BEGIN OF STATUS_ZFIDT014                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT014                      .
CONTROLS: TCTRL_ZFIDT014
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT014                      .
TABLES: ZFIDT014                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
