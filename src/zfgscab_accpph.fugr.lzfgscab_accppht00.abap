*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_ACCPPH..................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_ACCPPH                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_ACCPPH                .
CONTROLS: TCTRL_ZFGSCAB_ACCPPH
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_ACCPPH                .
TABLES: ZFGSCAB_ACCPPH                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
