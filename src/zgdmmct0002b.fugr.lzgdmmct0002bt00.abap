*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMCT0002B....................................*
DATA:  BEGIN OF STATUS_ZGDMMCT0002B                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMCT0002B                  .
CONTROLS: TCTRL_ZGDMMCT0002B
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMCT0002B                  .
TABLES: ZGDMMCT0002B                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
