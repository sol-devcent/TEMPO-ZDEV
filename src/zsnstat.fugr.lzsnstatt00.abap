*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSNSTAT.........................................*
DATA:  BEGIN OF STATUS_ZSNSTAT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSNSTAT                       .
CONTROLS: TCTRL_ZSNSTAT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSNSTAT                       .
TABLES: ZSNSTAT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
