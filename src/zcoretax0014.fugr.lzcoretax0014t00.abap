*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCORETAX0014....................................*
DATA:  BEGIN OF STATUS_ZCORETAX0014                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCORETAX0014                  .
CONTROLS: TCTRL_ZCORETAX0014
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCORETAX0014                  .
TABLES: ZCORETAX0014                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
