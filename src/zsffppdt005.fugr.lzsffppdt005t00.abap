*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSFFPPDT005.....................................*
DATA:  BEGIN OF STATUS_ZSFFPPDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSFFPPDT005                   .
CONTROLS: TCTRL_ZSFFPPDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSFFPPDT005                   .
TABLES: ZSFFPPDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
