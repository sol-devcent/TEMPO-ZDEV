*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCORETAX0013....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0013                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0013                  .
CONTROLS: TCTRL_ZCORETAX0013
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCORETAX0013                  .
TABLES: ZCORETAX0013                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
