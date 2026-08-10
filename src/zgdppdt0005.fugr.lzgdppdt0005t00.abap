*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDPPDT0005.....................................*
DATA:  BEGIN OF STATUS_ZGDPPDT0005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDPPDT0005                   .
CONTROLS: TCTRL_ZGDPPDT0005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDPPDT0005                   .
TABLES: ZGDPPDT0005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
