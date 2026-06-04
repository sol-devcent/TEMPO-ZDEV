*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSFFPPDT004.....................................*
DATA:  BEGIN OF STATUS_ZSFFPPDT004                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSFFPPDT004                   .
CONTROLS: TCTRL_ZSFFPPDT004
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSFFPPDT004                   .
TABLES: ZSFFPPDT004                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
