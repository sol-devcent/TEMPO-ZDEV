*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMCT0002.....................................*
DATA:  BEGIN OF STATUS_ZGDMMCT0002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMCT0002                   .
CONTROLS: TCTRL_ZGDMMCT0002
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZGDMMCT0002                   .
TABLES: ZGDMMCT0002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
