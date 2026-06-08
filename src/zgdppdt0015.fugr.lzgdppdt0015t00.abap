*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDPPDT0015.....................................*
DATA:  BEGIN OF STATUS_ZGDPPDT0015                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDPPDT0015                   .
CONTROLS: TCTRL_ZGDPPDT0015
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDPPDT0015                   .
TABLES: ZGDPPDT0015                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
