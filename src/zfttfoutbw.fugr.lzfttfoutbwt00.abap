*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTTFOUTBW......................................*
DATA:  BEGIN OF STATUS_ZFTTFOUTBW                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTTFOUTBW                    .
CONTROLS: TCTRL_ZFTTFOUTBW
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTTFOUTBW                    .
TABLES: ZFTTFOUTBW                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
