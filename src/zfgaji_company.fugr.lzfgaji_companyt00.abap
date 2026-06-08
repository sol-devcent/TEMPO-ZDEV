*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGAJI_COMPANY..................................*
DATA:  BEGIN OF STATUS_ZFGAJI_COMPANY                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGAJI_COMPANY                .
CONTROLS: TCTRL_ZFGAJI_COMPANY
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGAJI_COMPANY                .
TABLES: ZFGAJI_COMPANY                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
