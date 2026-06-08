*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_CONTROL..................................*
DATA:  BEGIN OF STATUS_ZFGAJI_CONTROL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_CONTROL                .
CONTROLS: TCTRL_ZFGAJI_CONTROL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_CONTROL                .
TABLES: ZFGAJI_CONTROL                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
