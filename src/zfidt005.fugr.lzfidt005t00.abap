*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT005........................................*
DATA:  BEGIN OF STATUS_ZFIDT005                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT005                      .
CONTROLS: TCTRL_ZFIDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT005                      .
TABLES: ZFIDT005                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
