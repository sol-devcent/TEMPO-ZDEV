*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSNOMOR.......................................*
DATA:  BEGIN OF STATUS_ZFGSNOMOR                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSNOMOR                     .
CONTROLS: TCTRL_ZFGSNOMOR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSNOMOR                     .
TABLES: ZFGSNOMOR                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
