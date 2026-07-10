*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_MAP.....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_MAP                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_MAP                   .
CONTROLS: TCTRL_ZFGSCAB_MAP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_MAP                   .
TABLES: ZFGSCAB_MAP                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
