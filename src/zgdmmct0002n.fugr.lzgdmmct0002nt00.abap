*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMCT0002N....................................*
DATA:  BEGIN OF STATUS_ZGDMMCT0002N                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMCT0002N                  .
CONTROLS: TCTRL_ZGDMMCT0002N
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMCT0002N                  .
TABLES: ZGDMMCT0002N                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
