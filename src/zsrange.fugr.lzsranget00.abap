*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSRANGE.........................................*
DATA:  BEGIN OF STATUS_ZSRANGE                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSRANGE                       .
CONTROLS: TCTRL_ZSRANGE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSRANGE                       .
TABLES: ZSRANGE                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
