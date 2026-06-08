*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_HKONT....................................*
DATA:  BEGIN OF STATUS_ZFGAJI_HKONT                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_HKONT                  .
CONTROLS: TCTRL_ZFGAJI_HKONT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_HKONT                  .
TABLES: ZFGAJI_HKONT                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
