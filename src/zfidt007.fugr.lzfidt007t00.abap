*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT007........................................*
DATA:  BEGIN OF STATUS_ZFIDT007                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT007                      .
CONTROLS: TCTRL_ZFIDT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT007                      .
TABLES: ZFIDT007                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
