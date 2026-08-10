*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDPPDT0006.....................................*
DATA:  BEGIN OF STATUS_ZGDPPDT0006                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDPPDT0006                   .
CONTROLS: TCTRL_ZGDPPDT0006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDPPDT0006                   .
TABLES: ZGDPPDT0006                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
