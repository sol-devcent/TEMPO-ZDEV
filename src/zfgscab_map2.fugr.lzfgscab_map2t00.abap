*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_MAP2....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_MAP2                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_MAP2                  .
CONTROLS: TCTRL_ZFGSCAB_MAP2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_MAP2                  .
TABLES: ZFGSCAB_MAP2                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
