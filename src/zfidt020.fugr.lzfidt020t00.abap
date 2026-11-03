*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT020........................................*
DATA:  BEGIN OF STATUS_ZFIDT020                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT020                      .
CONTROLS: TCTRL_ZFIDT020
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT020                      .
TABLES: ZFIDT020                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
