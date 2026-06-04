*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCCOPA..........................................*
DATA:  BEGIN OF STATUS_ZCCOPA                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCCOPA                        .
CONTROLS: TCTRL_ZCCOPA
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCCOPA                        .
TABLES: ZCCOPA                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
