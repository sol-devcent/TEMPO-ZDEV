*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTOP...........................................*
DATA:  BEGIN OF STATUS_ZFTOP                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTOP                         .
CONTROLS: TCTRL_ZFTOP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTOP                         .
TABLES: ZFTOP                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
