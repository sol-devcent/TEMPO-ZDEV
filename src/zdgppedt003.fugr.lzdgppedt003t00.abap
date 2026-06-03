*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDGPPEDT003.....................................*
DATA:  BEGIN OF STATUS_ZDGPPEDT003                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDGPPEDT003                   .
CONTROLS: TCTRL_ZDGPPEDT003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDGPPEDT003                   .
TABLES: ZDGPPEDT003                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
