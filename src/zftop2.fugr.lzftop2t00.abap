*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTOP2..........................................*
DATA:  BEGIN OF STATUS_ZFTOP2                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTOP2                        .
CONTROLS: TCTRL_ZFTOP2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTOP2                        .
TABLES: ZFTOP2                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
