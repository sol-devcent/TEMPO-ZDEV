*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSFFPPDT002.....................................*
DATA:  BEGIN OF STATUS_ZSFFPPDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSFFPPDT002                   .
CONTROLS: TCTRL_ZSFFPPDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSFFPPDT002                   .
TABLES: ZSFFPPDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
