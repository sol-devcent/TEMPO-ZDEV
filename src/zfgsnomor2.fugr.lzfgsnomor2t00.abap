*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSNOMOR2......................................*
DATA:  BEGIN OF STATUS_ZFGSNOMOR2                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSNOMOR2                    .
CONTROLS: TCTRL_ZFGSNOMOR2
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFGSNOMOR2                    .
TABLES: ZFGSNOMOR2                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
