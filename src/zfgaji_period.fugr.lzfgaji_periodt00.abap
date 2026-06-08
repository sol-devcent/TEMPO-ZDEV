*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_PERIOD...................................*
DATA:  BEGIN OF STATUS_ZFGAJI_PERIOD                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_PERIOD                 .
CONTROLS: TCTRL_ZFGAJI_PERIOD
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_PERIOD                 .
TABLES: ZFGAJI_PERIOD                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
