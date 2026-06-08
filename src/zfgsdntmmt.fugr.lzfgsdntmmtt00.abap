*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSDNTMMT......................................*
DATA:  BEGIN OF STATUS_ZFGSDNTMMT                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSDNTMMT                    .
CONTROLS: TCTRL_ZFGSDNTMMT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSDNTMMT                    .
TABLES: ZFGSDNTMMT                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
