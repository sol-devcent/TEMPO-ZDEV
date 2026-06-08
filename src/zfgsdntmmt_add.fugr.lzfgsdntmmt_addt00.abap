*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSDNTMMT_ADD..................................*
DATA:  BEGIN OF STATUS_ZFGSDNTMMT_ADD                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSDNTMMT_ADD                .
CONTROLS: TCTRL_ZFGSDNTMMT_ADD
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSDNTMMT_ADD                .
TABLES: ZFGSDNTMMT_ADD                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
