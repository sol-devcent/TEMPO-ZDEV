*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT006........................................*
DATA:  BEGIN OF STATUS_ZFIDT006                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT006                      .
CONTROLS: TCTRL_ZFIDT006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT006                      .
TABLES: ZFIDT006                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
