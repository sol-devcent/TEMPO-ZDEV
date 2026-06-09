*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSLOC2..........................................*
DATA:  BEGIN OF STATUS_ZSLOC2                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSLOC2                        .
CONTROLS: TCTRL_ZSLOC2
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSLOC2                        .
TABLES: ZSLOC2                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
