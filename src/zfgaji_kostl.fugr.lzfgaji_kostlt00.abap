*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_KOSTL....................................*
DATA:  BEGIN OF STATUS_ZFGAJI_KOSTL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_KOSTL                  .
CONTROLS: TCTRL_ZFGAJI_KOSTL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_KOSTL                  .
TABLES: ZFGAJI_KOSTL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
