*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDTXDT0025.....................................*
DATA:  BEGIN OF STATUS_ZGDTXDT0025                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDTXDT0025                   .
CONTROLS: TCTRL_ZGDTXDT0025
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDTXDT0025                   .
TABLES: ZGDTXDT0025                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
