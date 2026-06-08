*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_PROSES...................................*
DATA:  BEGIN OF STATUS_ZFGAJI_PROSES                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_PROSES                 .
CONTROLS: TCTRL_ZFGAJI_PROSES
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_PROSES                 .
TABLES: ZFGAJI_PROSES                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
