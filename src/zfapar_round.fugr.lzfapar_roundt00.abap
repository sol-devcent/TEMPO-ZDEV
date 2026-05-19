*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFAPAR_ROUND....................................*
DATA:  BEGIN OF STATUS_ZFAPAR_ROUND                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFAPAR_ROUND                  .
CONTROLS: TCTRL_ZFAPAR_ROUND
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFAPAR_ROUND                  .
TABLES: ZFAPAR_ROUND                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
