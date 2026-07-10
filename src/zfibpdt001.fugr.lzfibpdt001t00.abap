*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIBPDT001......................................*
DATA:  BEGIN OF STATUS_ZFIBPDT001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIBPDT001                    .
CONTROLS: TCTRL_ZFIBPDT001
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFIBPDT001                    .
TABLES: ZFIBPDT001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
