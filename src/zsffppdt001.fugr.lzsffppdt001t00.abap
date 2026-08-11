*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSFFPPDT001.....................................*
DATA:  BEGIN OF STATUS_ZSFFPPDT001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSFFPPDT001                   .
CONTROLS: TCTRL_ZSFFPPDT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSFFPPDT001                   .
TABLES: ZSFFPPDT001                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
