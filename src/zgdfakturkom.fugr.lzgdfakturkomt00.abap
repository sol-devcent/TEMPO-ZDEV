*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDFAKTURKOM....................................*
DATA:  BEGIN OF STATUS_ZGDFAKTURKOM                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDFAKTURKOM                  .
CONTROLS: TCTRL_ZGDFAKTURKOM
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDFAKTURKOM                  .
TABLES: ZGDFAKTURKOM                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
