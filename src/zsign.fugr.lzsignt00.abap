*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSIGN...........................................*
DATA:  BEGIN OF STATUS_ZSIGN                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSIGN                         .
CONTROLS: TCTRL_ZSIGN
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZSIGN                         .
TABLES: ZSIGN                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
