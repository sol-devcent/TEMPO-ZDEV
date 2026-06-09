*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMCT0002A....................................*
DATA:  BEGIN OF STATUS_ZGDMMCT0002A                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMCT0002A                  .
CONTROLS: TCTRL_ZGDMMCT0002A
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMCT0002A                  .
TABLES: ZGDMMCT0002A                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
