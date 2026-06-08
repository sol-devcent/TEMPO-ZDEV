*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_LOKASI...................................*
DATA:  BEGIN OF STATUS_ZFGAJI_LOKASI                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_LOKASI                 .
CONTROLS: TCTRL_ZFGAJI_LOKASI
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_LOKASI                 .
TABLES: ZFGAJI_LOKASI                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
