*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIBPHD001......................................*
DATA:  BEGIN OF STATUS_ZFIBPHD001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIBPHD001                    .
CONTROLS: TCTRL_ZFIBPHD001
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFIBPHD001                    .
TABLES: ZFIBPHD001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
