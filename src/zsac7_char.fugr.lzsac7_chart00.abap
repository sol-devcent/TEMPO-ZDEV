*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSAC7_CHAR......................................*
DATA:  BEGIN OF STATUS_ZSAC7_CHAR                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSAC7_CHAR                    .
CONTROLS: TCTRL_ZSAC7_CHAR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSAC7_CHAR                    .
TABLES: ZSAC7_CHAR                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
