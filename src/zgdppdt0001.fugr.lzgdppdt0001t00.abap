*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDPPDT0001.....................................*
DATA:  BEGIN OF STATUS_ZGDPPDT0001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDPPDT0001                   .
CONTROLS: TCTRL_ZGDPPDT0001
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZGDPPDT0001                   .
TABLES: ZGDPPDT0001                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
