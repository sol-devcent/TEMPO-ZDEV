*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATIN_NR......................................*
DATA:  BEGIN OF STATUS_ZFVATIN_NR                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATIN_NR                    .
CONTROLS: TCTRL_ZFVATIN_NR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATIN_NR                    .
TABLES: ZFVATIN_NR                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
