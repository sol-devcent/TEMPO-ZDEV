*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTTFOUTBD......................................*
DATA:  BEGIN OF STATUS_ZFTTFOUTBD                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTTFOUTBD                    .
CONTROLS: TCTRL_ZFTTFOUTBD
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTTFOUTBD                    .
TABLES: ZFTTFOUTBD                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
