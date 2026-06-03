*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDGPPEDT007.....................................*
DATA:  BEGIN OF STATUS_ZDGPPEDT007                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDGPPEDT007                   .
CONTROLS: TCTRL_ZDGPPEDT007
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZDGPPEDT007                   .
TABLES: ZDGPPEDT007                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
