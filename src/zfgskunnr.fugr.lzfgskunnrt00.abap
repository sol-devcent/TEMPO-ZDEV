*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSKUNNR.......................................*
DATA:  BEGIN OF STATUS_ZFGSKUNNR                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSKUNNR                     .
CONTROLS: TCTRL_ZFGSKUNNR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSKUNNR                     .
TABLES: ZFGSKUNNR                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
