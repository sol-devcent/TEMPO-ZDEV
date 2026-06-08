*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDGFIDT006......................................*
DATA:  BEGIN OF STATUS_ZDGFIDT006                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDGFIDT006                    .
CONTROLS: TCTRL_ZDGFIDT006
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDGFIDT006                    .
TABLES: ZDGFIDT006                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
